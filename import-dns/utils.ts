async function commandExists(command: string) {
    const result = await $`command -v ${command} &>/dev/null`.nothrow()
    return result.exitCode === 0
}

async function getTofuOrTerraform(): Promise<Result<string>> {
    for (const command of ["tofu", "terraform"]) {
        if (await commandExists(command)) {
            return command
        }
    }
    return ErrTofuOrTerraformNotFound
}