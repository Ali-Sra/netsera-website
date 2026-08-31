export type Project = {
  id: number;
  title: string;
  slug: string;
  shortDescription?: string | null;
  description?: string | null;
  imageUrl?: string | null;
  projectUrl?: string | null;
  githubUrl?: string | null;
  displayOrder: number;
};

export type Service = {
  id: number;
  title: string;
  slug: string;
  description?: string | null;
  icon?: string | null;
  displayOrder: number;
};

export type ContactRequest = {
  name: string;
  email: string;
  subject?: string;
  message: string;
};

export type ContactResponse = {
  id?: number;
  createdAtUtc?: string;
  status?: string;
};
