export const homeStats = [
  { value: 'M365', label: 'Identity & Collaboration' },
  { value: 'AD', label: 'Windows Infrastructure' },
  { value: 'VM', label: 'Virtualization' },
  { value: 'SEC', label: 'Network Security' },
] as const;

export const serviceHighlights = [
  {
    icon: 'windows',
    title: 'Microsoft Stack',
    description: 'Windows Server, Active Directory, Microsoft 365 and Entra ID.',
  },
  {
    icon: 'server',
    title: 'Infrastructure',
    description: 'Virtualization, systems operations and reliable service delivery.',
  },
  {
    icon: 'shield',
    title: 'Security',
    description: 'Firewalling, segmentation, hardening and operational visibility.',
  },
  {
    icon: 'sitemap',
    title: 'Networking',
    description: 'Routing, switching, VLANs and practical troubleshooting.',
  },
] as const;
