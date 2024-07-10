## helmfiles

> [!IMPORTANT]
> These files are exemplars. They render on Unique infrastructure but won't render on any other infrastructure. They are not meant to be used as is. They are meant to be used as a reference for your own helmfiles if you decide to use helmfile.

### helmfile

[helmfile](https://helmfile.readthedocs.io) is not offered or invented by Unique. Given that you have access to this repository means you have signalled that you fulfil the Unique FinanceGPT [Pre-Installation Checklist](https://unique-ch.atlassian.net/wiki/x/HAC-Hg) where as understanding helm is essential.

Refer to the [helmfile docs](https://helmfile.readthedocs.io) to learn more about the helmfile syntax and how to use it.

Some usage examples include:

```bash
helm plugin install https://github.com/databus23/helm-diff
helmfile -e <env>-prod -f helmfiles/<file>.yaml diff  
helmfile -e <env>-prod -f helmfiles/<file>.yaml apply  
helmfile -e <env>-prod -f helmfiles/<file>.yaml -l name=<release> diff  
helmfile -e <env>-prod -f helmfiles/<file>.yaml -l name=<release> apply

cd helmfiles
helmfile -e your-tenant-alias -f examples/system.yaml template
helmfile -e your-tenant-alias -f examples/chat.yaml template
helmfile -e your-tenant-alias -f examples/app-repo.yaml template
```

#### Custom helmfiles
Unique can and will not avoid you customizing the helmfile to your needs. Given Uniques Release Notes and Changelogs. You will be able to advance your helmfiles to the latest version of the Unique infrastructure. You can always use the example files in this repo to see the latest changes and how to apply them to your helmfiles as well as to compare them to your own helmfiles.