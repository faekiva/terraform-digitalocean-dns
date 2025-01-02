import { DomainRecordsSchema, Flags, NextLink } from "./types.ts";
import { DomainRecord } from "./types.ts";
import { makeImportStatement } from "./make-import-statement.ts";

async function getDomainRecords(args: Flags) {
    const output: DomainRecord[] = [];
    let next: string | undefined =
        `https://api.digitalocean.com/v2/domains/${args.domain}/records`;

    while (next) {
        console.log(next)
        const response = await fetch(
            next,
            {
                headers: {
                    "Authorization": `Bearer ${args.digitalOceanApiKey}`,
                },
            },
        );
        const responseJson = await response.json();
        const domainRecords = DomainRecordsSchema.parse(responseJson)
        console.log(domainRecords)
        output.push(...domainRecords);
        next = NextLink.parse(responseJson);
    }

    return output;
}

export async function main(args: Flags) {
    console.log("here")
    const domainRecords = await getDomainRecords(args);
    console.log(domainRecords)
    for (const record of domainRecords) {
        const statement = await makeImportStatement(args, record);
        if (statement instanceof Error) {
            throw statement
        }
        console.log(statement)
    }
    console.log("done")
}
