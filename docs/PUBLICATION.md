# Publication provenance and safe maintenance

The owner authorized a privacy-clean public successor while keeping the original
repository private. Later private commits and PR references are deliberately absent
from the successor; rewriting only a branch would not isolate private PR history.

## History construction

Only the annotated `v1.0.0` ref was fetched, with automatic tag following disabled,
from the audited local repository into an entirely separate Git repository. Its
six commits and tagger metadata contain placeholder identities, with no personal
email addresses. The original annotated tag object remains
`8d3c101921b33f3a2df9ba6fccc6d882eb944a11` at commit
`1f4af30dbfbb02331d886e1605b11a643f7ab3e6`.

The diff from that baseline to the reviewed private final source was applied as
fresh commit `9d37cc38ad8c0b5331720674c57adc2b64b55136`, authored and committed
with the account's verified GitHub noreply identity. Its tree was exactly
`3a356c6197de5a72bec3ded605838a33087fbd63`, matching the reviewed source tree.
Publication documentation changes follow separately. Private later commits, PR
refs, the original v1.0.1 tag and old object database were never imported.

Only `main`, the preserved `v1.0.0` and a fresh annotated `v1.0.1` are pushed.
Every reachable object, author/committer/tagger and historical tracked path is
checked. The successor starts private; both hosted jobs must pass before release
and public visibility. Exact results appear in [CI evidence](evidence/github-ci-verification.json)
and the [release](https://github.com/RyanBarnes321/it-operations-lab/releases/tag/v1.0.1).
Generic historical temporary-directory examples are documentation, not copied
recovery artifacts. No files from system temporary storage were imported.

## Local maintenance boundary

`/opt/it-operations-lab` remains the live operational checkout, with its original
history and private local state. Its remote targets the private archive, and direct
push is disabled. Never point that checkout at the public repository.

`/opt/it-operations-lab-public` is the independent clean publication checkout. Its
origin targets the successor. Make future public source/documentation commits here
with the GitHub noreply identity, review the diff, run source/history checks and
push explicit branches/tags. Never merge, fetch or push the operational checkout's
post-v1.0.0 history into this checkout. Transfer later reviewed source edits as file
diffs only; never copy Git internals, secret, backup or runtime directories.

No Docker services, volumes, host networking, encryption or power configuration
was changed to publish this repository. The private archive retains its original
PRs, releases and history. Historical lab evidence and accepted limitations remain
as documented; no missing screenshot or recovery result was fabricated.
