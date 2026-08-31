import { apiFetch } from './client';
import type {
  ContactRequest,
  ContactResponse,
  Project,
  Service,
} from '../types/api';

export const publicApi = {
  getProjects: () => apiFetch<Project[]>('/api/content/projects'),

  getServices: () => apiFetch<Service[]>('/api/content/services'),

  sendContact: (payload: ContactRequest) =>
    apiFetch<ContactResponse>('/api/contact', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getLiveHealth: () => apiFetch<unknown>('/health/live'),

  getReadyHealth: () => apiFetch<unknown>('/health/ready'),
};
