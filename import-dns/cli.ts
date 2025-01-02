import { parseArgs } from "jsr:@std/cli/parse-args";
import { FlagsSchema } from "./types.ts";
import { main } from "./import-dns.ts"



const flags = parseArgs(Deno.args, {
    string: ["domain", "root-resource"]
});


const validatedFlags = FlagsSchema.parse(flags)

await main(validatedFlags)