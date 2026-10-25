# Ghost-Busters-AD 👻

**Hunt down forgotten Active Directory objects before they come back to haunt you.**

Active Directory has a long memory. Employees leave, servers are retired, applications are replaced, but accounts and permissions can remain for years.

**Ghost-Busters-AD** is a collection of read-only PowerShell inventory checks intended to help Active Directory administrators identify accounts, computers and privileged group memberships that deserve a closer look. It produces local reports for manual review. It does **not** disable, delete, or modify AD objects.

## What it checks

| Check | Description | Output |
| --- | --- | --- |
| Privileged and sensitive groups | Enumerates recursive members and counts for 15 named AD groups, including Domain Admins, Enterprise Admins, DNSAdmins, Account Operators and Protected Users | `ad_priv_groups_<group>.txt`, `ad_priv_groups_count.txt` |
| Passwords that never expire | Lists enabled user accounts with `PasswordNeverExpires` set | `passwordneverexpires.txt`, `passwordneverexpires_count.txt` |
| Stale enabled users | Reports enabled users with a `LastLogonDate` older than 1,500 days (or missing) | `stale_accounts_1500days.txt`, `stale_accounts_1500days_count.txt` |
| Stale AdminCount users | Reports enabled users with `AdminCount > 0` whose `LastLogonDate` is older than 365 days (or missing) | `stale_admin_accounts_365days.txt`, `stale_admin_accounts_365days_count.txt` |
| Old passwords | Reports enabled users whose `PasswordLastSet` is older than 3,650 days (or missing), including a separate `AdminCount` subset | `password_age_10_years_users.txt`, `password_age_10_years_admins.txt` and count files |
| Computer inventory | Exports AD computer names, OS details, description, enabled status, last logon, password last set, distinguished name and a calculated 90-day `Stale` flag | `AD_allcomputers.csv` |

The group inventory checks: Administrators, Domain Admins, Enterprise Admins, DNSAdmins, Schema Admins, Account Operators, Backup Operators, Print Operators, Server Operators, Hyper-V Administrators, Remote Desktop Users, Group Policy Creator Owners, Remote Management Users, Network Configuration Operators and Protected Users.

## Requirements

- Windows PowerShell with the **ActiveDirectory** module (RSAT AD PowerShell tools or a domain controller).
- Connectivity to Active Directory and sufficient directory read permissions.
- Permission to create the chosen output directory on `C:\`.

The script's original instructions recommend running in an elevated PowerShell ISE on a domain controller. You should generally be able to run the AD read queries from an appropriate domain-joined management workstation with RSAT and suitable access, without signing in interactively to a domain controller.

## Usage

1. Review the script before running it and confirm the domain and account context.
2. Set the output folder near the top of the script:

   ```powershell
   $outputfolder = "domain_ghosts"
   ```

3. Review and adjust the three thresholds if needed:

   ```powershell
   $lastlogondays = "1500"  # stale enabled users
   $lastlogondays = "365"   # later reassigned for AdminCount users
   $passwordage = "3650"    # old passwords
   ```

   The computer stale threshold is separately hardcoded to **90 days**.

4. Run the script in a PowerShell session with the ActiveDirectory module available.

Results are written to `C:\domain_ghosts\` by default. Most reports are text files; the complete computer inventory is a CSV.

## How the computer stale flag works

The `Stale` column is `True` when **both** `LastLogonDate` and `PasswordLastSet` are older than 90 days. Missing dates also compare as older in this expression. This is a candidate for investigation, **not** proof that a machine can safely be removed.

## Important interpretation notes

- **Last logon is approximate:** `LastLogonDate` is based on the replicated `lastLogonTimestamp` attribute. It can lag behind actual authentication activity and should not be used as an exact logon audit trail.
- **AdminCount is not a privilege verdict:** `AdminCount=1` may remain after an account has been removed from a protected group. Confirm *current* privileged access separately.
- **Recursive group enumeration:** `Get-ADGroupMember -Recursive` expands nested membership; it is not a complete assessment of every privilege path or permission.
- **Group availability varies:** Some named groups might not be present or resolvable in every domain, and a failed lookup can generate an error. Check the console for errors.
- **Computer password age:** Domain-joined machines usually attempt machine account password changes periodically (typically every 30 days by default), but policies, disconnected systems and other conditions can affect this behavior.
- **Old does not necessarily mean unsafe:** Long-lived service accounts, noninteractive identities, intentionally disabled systems and legacy applications may be legitimate. Verify ownership and dependencies before remediation.
- **Output contents are sensitive:** Reports expose account names, group memberships and environment configuration. Store and share them securely. Avoid committing real assessment output to a public GitHub repository.
- **Output behavior:** The folder creation command can report that the folder already exists; the group-count report uses append redirection (`>>`), so repeated runs may append counts instead of replacing them. Other outputs are generally overwritten.
- **Naming:** Some output filenames contain the built-in threshold labels (for example, `1500days`, `365days`, and `10_years`), even if you change the corresponding variables.

## Scope

This is an **inventory and hygiene starting point**, not an automated cleanup tool, vulnerability scanner, or complete Active Directory security assessment. Review results before making changes. It does not enumerate stale group membership changes, identify all abandoned service accounts, or validate that an AD object is unused.

## Disclaimer

Provided **as-is**, for authorized administration and security assessment. Test in your environment and review the generated reports before taking action. No changes are made to Active Directory by the supplied queries.
