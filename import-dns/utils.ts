import {  encodeBase64 } from "jsr:@std/encoding/base64";



export async function base64sha256(input: string): Promise<string> {
    const inputBuffer = new TextEncoder().encode(input);
    const hashBuffer = await crypto.subtle.digest("SHA-256",inputBuffer)
    return encodeBase64(hashBuffer)
}