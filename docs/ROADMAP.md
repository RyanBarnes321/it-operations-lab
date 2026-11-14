# Future development roadmap

These are proposals, not implemented features or v1.0 promises.

1. Preserve the [release gates](RELEASE-CHECKLIST.md) and clean publication history.
   Keep private operational history isolated; see [publication](PUBLICATION.md).
   Add the real, reviewed screenshot if recovered.
2. Evaluate power reliability: replacement battery or available UPS, firmware power
   restoration support and a documented reboot drill. Boot/LUKS changes need their
   own design and authorization; manual unlock remains the present boundary.
3. Establish backup cadence, capacity and retention records, independently located
   encrypted storage and periodic recovery drills. Measure recovery time and data
   age before proposing RPO/RTO targets or scheduling deletion.
4. Consider log rotation and centralized logging when justified by troubleshooting
   needs and resource budget. Loki/Alloy remain deferred; neither is deployed.
5. Review image vulnerabilities and digest pinning, then plan compatible upgrades
   with backup and rollback checks. Add external alert delivery only with an
   approved destination and testable delivery requirements.
6. Consider monitoring a backend portfolio application as a separate increment,
   with explicit scope and credentials. No changes to the Service Desk API or
   AI Document Processing API repositories are part of this release.
