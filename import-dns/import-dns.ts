import { z } from "npm:zod@^3.24.1";
import zonefile from 'npm:dns-zonefile'
import { $ } from 'npm:zx@8.3.0'
import { Try } from "./result.ts";
import type { Result } from "./result.ts";

const domain = "leftist.gay"
const ErrTofuOrTerraformNotFound = new Error("tofu or terraform required to be installed to parse this.")
const ErrCouldntGetHashed = new Error("Error getting hashed value")

type ArrayElement<T> = T extends (infer U)[] ? U : never;
type TerraformCompatibleRecordType = "A" | "AAAA" | "CAA" | "CNAME" | "MX" | "NS" | "SRV" | "TXT"
type DNSRecord = ArrayElement<zonefile.DNSZone[Lowercase<TerraformCompatibleRecordType>]>
// type CanMakeKey {

// }

function getTokenFromTFVars() {
    const tfVars = Deno.readTextFileSync(".tfvars")
    console.log(tfVars)
    const token = tfVars.match(/digital_ocean_api_key="(.*)"/)?.[1]
    return token
}

async function commandExists(command: string) {
    const result = await $`command -v ${command} &>/dev/null`.nothrow()
    return result.exitCode === 0
}

async function getTofuOrTerraform(): Promise<Result<string>> {
    for (const command of ["tofu", "terraform"]) {
        if (await commandExists(command)) {
            return command
        }
    }
    return ErrTofuOrTerraformNotFound
}

function getValue(record: DNSRecord) {
    let value: string
    if ("ip" in record) {
        value = record.ip
    } else if ("host" in record) {
        value = record.host
    } else if ("value" in record) {
        value = record.value
    } else if ("alias" in record) {
        value = record.alias
    } else if ("txt" in record) {
        value = record.txt
    } else {
        value = record.target
    }
    return value
}

async function makeKey(recordType: TerraformCompatibleRecordType, record: DNSRecord): Promise<Result<string>> {
    const uncompressed = `${recordType} | ${record.name} | ${getValue(record)}`

    if (uncompressed.length <= 64) {
        return uncompressed
    }

    const command = await getTofuOrTerraform()
    if (command instanceof Error) {
        return command
    }

    const retVal = await Try(async ()=> {
        await $`${command} apply -var getHashed=${uncompressed}`
        const hashedOutputResult = await $`${command} output hashed`
        return hashedOutputResult.text().match(/"(.*)"/)?.[1]
    })
    await $`rm -f terraform.tfstate`
    if (retVal instanceof Error) {
        return retVal
    }
    if (!retVal) {
        return ErrCouldntGetHashed
    }
    return retVal
}

const domainInfo = await (async () => {
        const response = await fetch(
            `https://api.digitalocean.com/v2/domains/${domain}/records`,
            {
                headers: {
                    "Authorization": `Bearer ${getTokenFromTFVars()}`
                }
            }
        )
        // If I was caring about performance and reusing this function I'd define this outside
        const DODomainSchema = z.object(
            {
                "domain": z.object({
                    "name": z.string(),
                    "ttl": z.number(),
                    "zone_file": z.string()
                })
            }
        ).transform(o => {
            return {
                name: o.domain.name,
                ttl: o.domain.ttl,
                zone_records: o.domain.zone_file
            }
        })
    
        return DODomainSchema.parse(await response.json())
    })()
const zoneFile = zonefile.parse(domainInfo.zone_records)
console.log(zoneFile)
