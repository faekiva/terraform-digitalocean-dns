import { $ } from "npm:zx@8.3.0";
import {Try, type AsyncResult }  from "./result.ts";
import { DomainRecord, Flags } from "./types.ts";
import { base64sha256 } from "./utils.ts";

const ErrTofuOrTerraformNotFound = new Error(
  "tofu or terraform required to be installed to parse this."
);

async function commandExists(command: string) {
  const result = await $`command -v ${command} &>/dev/null`.nothrow();
  return result.exitCode === 0;
}

async function getTofuOrTerraform(): AsyncResult<string> {
  for (const command of ["tofu", "terraform"]) {
    if (await commandExists(command)) {
      return command;
    }
  }
  return ErrTofuOrTerraformNotFound;
}

function parseData(record: DomainRecord){
  const withDotIfURL = Try(()=> {
    if (!record.data.endsWith(".")) {
      let data = record.data
      if (!data.includes("://")) {
        data = "https://"+data
      }
      new URL(data)
      return record.data + "."
    }
    return record.data
  })
  if (withDotIfURL instanceof Error) {
    return record.data
  }
  return withDotIfURL
}

export async function makeImportStatement(args: Flags, record: DomainRecord): AsyncResult<string> {
  const command = await getTofuOrTerraform();
  if (command instanceof Error) {
    return command;
  }
  const data = parseData(record)
  const uncompressed = `${record.type} | ${record.name} | ${data}`;
  const keyUsed = uncompressed.length > 64 ? await base64sha256(uncompressed) : uncompressed

  return `${command} import -var-file=".tfvars" '${args.rootResource}.digitalocean_record.records["${keyUsed}"]' '${args.domain},${record.id}' || echo import failed for "${uncompressed}"`;
}
