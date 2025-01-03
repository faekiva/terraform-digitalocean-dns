import { parseArgs } from "jsr:@std/cli/parse-args";
import { FlagsSchema } from "./types.ts";
import { main } from "./import-dns.ts"

const flags = parseArgs(Deno.args, {
    string: ["domain", "root-resource", "digital-ocean-api-key"]
});


const result = FlagsSchema.safeParse(flags)

if (!result.success) {
    console.error(result.error.format())
    Deno.exit(1)
}

await main(result.data)