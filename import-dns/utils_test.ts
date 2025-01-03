import { expect } from "jsr:@std/expect";
import { base64sha256 } from "./utils.ts";

Deno.test("should have the same thing as terraform for base64sha256", async ()=> {
    expect(await base64sha256("asd")).toBe("aIeH2P8UTFAsf1z/qv4sxYjYYHn53ogwTCawy5nOkcY=")
})