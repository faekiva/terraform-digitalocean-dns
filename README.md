# terraform-digitalocean-dns

An easier way to manage digitalocean dns through terraform. Designed to take in its values via a single yaml or JSON file to allow for easier programmability and DRYer syntax. See [here](./tests/basic_pass/test_config.yml) for an example.

Syntactic sugar is available for ATProto identifier records specifically, since that's a use case I use often!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.44.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_domain.domain](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/domain) | resource |
| [digitalocean_record.atproto](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.records](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | n/a | `number` | `1799` | no |
| <a name="input_values"></a> [values](#input\_values) | n/a | <pre>object({<br/>    domain = string<br/>    records = optional(map(list(object({<br/>      name  = string<br/>      value = string<br/>      ttl = optional(number, -1)<br/>    }))), {}),<br/>    atproto = optional(list(object({<br/>      handle = string<br/>      did    = string<br/>    })), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atproto"></a> [atproto](#output\_atproto) | n/a |
| <a name="output_records"></a> [records](#output\_records) | n/a |
<!-- END_TF_DOCS -->

## TODOs

On my roadmap for this project are

- JSON Schema validation for the YAML file syntax
- Accept [zone files](https://www.cloudflare.com/learning/dns/glossary/dns-zone/) as input.
- Separate parsing logic out into its own module, to allow this same format to be used with other DNS providers.

If any of these interest you, or there's another feature you want, feel free to reach out to me by opening an issue on this repo or [tagging me on bsky](https://bsky.app/profile/leftist.gay) and I'll see what I can do! You can also feel free to open a PR and I'll take a look!