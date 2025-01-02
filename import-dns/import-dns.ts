import { DomainRecordsSchema, Flags, NextLink } from "./types.ts";
import { DomainRecord } from "./types.ts";
import { makeImportStatement } from "./make-import-statement.ts";

async function getDomainRecords(args: Flags) {
    const output: DomainRecord[] = [];
    let next: string | undefined =
        `https://api.digitalocean.com/v2/domains/${args.domain}/records`;

    while (next) {
        const response = await fetch(
            next,
            {
                headers: {
                    "Authorization": `Bearer ${args.digitalOceanApiKey}`,
                },
            },
        );
        const responseJson = await response.json();
        output.push(...DomainRecordsSchema.parse(responseJson));
        next = NextLink.parse(responseJson);
    }

    return output;
}

export async function main(args: Flags) {
    const domainRecords = await getDomainRecords(args);
    for (const record of domainRecords) {
        makeImportStatement(args, record);
    }
}
