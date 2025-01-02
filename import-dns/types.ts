import { z } from "npm:zod@^3.24.1";
import type {ArrayElement} from "./result.ts"


export const FlagsSchema = z.object({
    domain: z.string(),
    "root-resource": z.string()
}).strict().transform(o => {
    return {
        "domain": o.domain,
        "rootResource": o["root-resource"]
    }
})

export type Flags = z.output<typeof FlagsSchema>

export const DomainRecordsSchema = (()=> {
    const terraformCompatibleRecordTypes = ["A", "AAAA", "CAA", "CNAME", "MX", "NS", "SRV", "TXT"] as const;
    // type TerraformCompatibleRecordType =  typeof terraformCompatibleRecordTypes[number]
    const domainRecordTypeless =
        {
            "id": z.number(),
            "name": z.string(),
            "data": z.string()
        }

    const DomainRecordsSchema = z.object({"domain_records": z.array(z.object({
        "type": z.string(),
        ...domainRecordTypeless
    }))}).transform(o => {
        return o.domain_records.filter(o => o.type in terraformCompatibleRecordTypes)
    }).pipe(
        z.array(z.object({
            "type": z.enum(terraformCompatibleRecordTypes),
            ...domainRecordTypeless
        }))
    )

    return DomainRecordsSchema
})()

export const NextLink = z.object(
    {
        "links": z.object({
            "pages": z.object({
                "next": z.string().optional()
            }).optional()
        })
    }
).transform(o => o.links.pages?.next).pipe(z.string().optional())

export type DomainRecord = ArrayElement<z.output<typeof DomainRecordsSchema>>