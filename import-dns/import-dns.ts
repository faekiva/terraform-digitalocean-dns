import { z } from "npm:zod@^3.24.1";
import { $ } from "npm:zx@8.3.0";
import { Try } from "./result.ts";
import type { Result } from "./result.ts";
import { DomainRecordsSchema, Flags, NextLink } from "./types.ts";
import { DomainRecord } from "./types.ts";

// const domain = "leftist.gay" as const

const ErrTofuOrTerraformNotFound = new Error(
    "tofu or terraform required to be installed to parse this.",
);
const ErrCouldntGetHashed = new Error("Error getting hashed value");

function getTokenFromTFVars() {
    const tfVars = Deno.readTextFileSync(".tfvars");
    console.log(tfVars);
    const token = tfVars.match(/digital_ocean_api_key="(.*)"/)?.[1];
    return token;
}

async function commandExists(command: string) {
    const result = await $`command -v ${command} &>/dev/null`.nothrow();
    return result.exitCode === 0;
}

async function getTofuOrTerraform(): Promise<Result<string>> {
    for (const command of ["tofu", "terraform"]) {
        if (await commandExists(command)) {
            return command;
        }
    }
    return ErrTofuOrTerraformNotFound;
}

async function makeKey(
    record: DomainRecord,
    command: string,
): Promise<Result<string>> {
    const uncompressed = `${record.type} | ${record.name} | ${record.data}`;

    if (uncompressed.length <= 64) {
        return uncompressed;
    }

    const retVal = await Try(async () => {
        await $`${command} apply -var getHashed=${uncompressed}`;
        const hashedOutputResult = await $`${command} output hashed`;
        return hashedOutputResult.text().match(/"(.*)"/)?.[1];
    });
    await $`rm -f terraform.tfstate`;
    if (retVal instanceof Error) {
        return retVal;
    }
    if (!retVal) {
        return ErrCouldntGetHashed;
    }
    return retVal;
}

async function makeImportStatement(args: Flags, record: DomainRecord) {
    const command = await getTofuOrTerraform();
    if (command instanceof Error) {
        return command;
    }
    return `${command} import ${args.rootResource}`;
}

export async function main(args: Flags) {
    const domainInfo = await (async () => {
        const output: DomainRecord[] = [];
        let next: string | undefined =
            `https://api.digitalocean.com/v2/domains/${args.domain}/records`;
        while (next) {
            const response = await fetch(
                next,
                {
                    headers: {
                        "Authorization": `Bearer ${getTokenFromTFVars()}`,
                    },
                },
            );
            const responseJson = await response.json();
            output.push(...DomainRecordsSchema.parse(responseJson));
            next = NextLink.parse(responseJson);
        }

        return output;
    })();
}
