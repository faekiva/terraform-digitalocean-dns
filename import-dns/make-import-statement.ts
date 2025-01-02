import { $ } from "npm:zx@8.3.0";
import type {Result }  from "./result.ts";
import { Try } from "./result.ts";
import { DomainRecord, Flags } from "./types.ts";

const ErrTofuOrTerraformNotFound = new Error(
  "tofu or terraform required to be installed to parse this."
);
const ErrCouldntGetHashed = new Error("Error getting hashed value");

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
  command: string
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
export async function makeImportStatement(args: Flags, record: DomainRecord) {
  const command = await getTofuOrTerraform();
  if (command instanceof Error) {
    return command;
  }
  return `${command} import ${args.rootResource}.digitalocean_record.records["${makeKey(record, command)}"] ${args.domain},${record.id}`;
}
