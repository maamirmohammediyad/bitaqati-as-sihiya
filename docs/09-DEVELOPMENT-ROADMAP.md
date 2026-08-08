# Development Roadmap — 12 Weeks (Solo Dev)

## Strategy

- **Backend-first** (Weeks 1-4): Core API, database, auth, basic CRUD. This unblocks mobile dev.
- **Parallel frontend & backend** (Weeks 5-9): Mobile features with backend integration.
- **Polish & deploy** (Weeks 10-12): Security hardening, testing, deployment.

## Week-by-Week Plan

### Phase 1: Foundation (Weeks 1-4)

#### Week 1 — Project Scaffolding
| Task | Details |
|------|---------|
| Laravel project setup | `laravel new bitaqati-api` with Sanctum, PostgreSQL config |
| Database migrations | All tables from schema design (users, patient_profiles, guardian_patient, etc.) |
| Models & relationships | Eloquent models with casts, relations, soft deletes |
| UUID setup | Configure UUID primary keys for all tables |
| Flutter project setup | `flutter create bitaqati` with folder structure, Riverpod, Dio |

**Deliverable:** Empty apps with database schema migrated and models defined.

#### Week 2 — Authentication Backend
| Task | Details |
|------|---------|
| JWT auth setup | Sanctum or tymon/jwt-auth |
| Register patient endpoint | FormRequest, Action, Resource |
| Register guardian endpoint | With optional PatientCode linking |
| Login / Logout / Refresh | Token management |
| Password reset | Email-based reset flow |
| Device token registration | FCM token storage |

**Deliverable:** Full auth API working, testable via Postman.

#### Week 3 — Auth Frontend + Core Layer
| Task | Details |
|------|---------|
| Dio client setup | Base URL, auth interceptor, error handling |
| Secure storage | Token persistence, auto-login |
| Riverpod auth provider | AuthNotifier, AuthState |
| Login screen | With role toggle |
| Registration screen | Patient registration flow |
| Guardian registration | With PatientCode field |
| GoRouter setup | Auth guard redirect, role-based shells |

**Deliverable:** User can register and login from the mobile app.

#### Week 4 — Patient Profile Backend
| Task | Details |
|------|---------|
| Patient profile CRUD | Complete, update, show profile |
| Guardian-patient linking | Link, list patients, authorization gate |
| Profile encryption | Custom Eloquent cast for encrypted fields |
| Audit log service | Log profile updates |
| Avatar upload | Supabase Storage integration |

**Deliverable:** Patient and guardian can manage profiles via API.

### Phase 2: Core Features (Weeks 5-8)

#### Week 5 — Patient & Guardian Profile Frontend
| Task | Details |
|------|---------|
| Patient dashboard screen | Home with quick actions and health card preview |
| Profile completion screen | Multi-step form for medical info |
| Guardian dashboard | Patient list, switch between patients |
| Guardian link screen | PatientCode input + relationship selector |
| Profile editing | Both patient and guardian views |
| Glassmorphism UI components | GlassCard, consistent styling |

**Deliverable:** Profile management flows complete.

#### Week 6 — Medical Files Backend
| Task | Details |
|------|---------|
| File upload endpoint | Supabase Storage upload + metadata DB record |
| File list endpoint | Paginated, filterable by type |
| File download endpoint | Signed URL generation |
| File soft delete | Delete from storage + DB |
| Authorization | Can:manage gate for patient/guardian |

#### Week 7 — Medical Files Frontend + Health Card
| Task | Details |
|------|---------|
| File list screen | Grid/list view with filter chips |
| Upload bottom sheet | File picker + type selector |
| File preview | Image viewer, PDF viewer |
| Health card QR generation | qr_flutter integration |
| Health card screen | Bank card design with glassmorphism |
| QR scan public endpoint | Emergency-only health card data |

**Deliverable:** Files and health card fully functional.

#### Week 8 — Emergency Contacts + SOS Backend
| Task | Details |
|------|---------|
| Emergency contacts CRUD API | Store/get/update/delete |
| SOS trigger endpoint | Create event, get location, send FCM |
| SOS resolve endpoint | Mark emergency as resolved |
| FCM notification setup | Send to all guardians of patient |
| Emergency history endpoint | List events with filter |

### Phase 3: Advanced Features (Weeks 9-10)

#### Week 9 — SOS & Emergency Frontend
| Task | Details |
|------|---------|
| SOS screen | Big red button with GPS, pulsing animation |
| Emergency mode UI | Red banner, status, resolve button |
| Emergency history screen | Timeline of past events |
| FCM handling | Receive notifications, navigate on tap |
| Guardian notification screen | In-app notification list |

**Deliverable:** Complete SOS flow end-to-end.

#### Week 10 — Hospital Finder
| Task | Details |
|------|---------|
| Hospitals seeder | Seed major hospitals data |
| Nearby hospitals API | Distance calculation, ordering |
| Google Maps integration | Map with pins, permissions |
| Hospital list screen | Cards with distance, call, navigate |
| Hospital detail screen | Full info + actions |
| Map view | Interactive map with hospital markers |

**Deliverable:** Hospital finder working with GPS.

### Phase 4: Admin & Polish (Weeks 11-12)

#### Week 11 — Admin Dashboard
| Task | Details |
|------|---------|
| Admin middleware | Route protection |
| Users management | List, search, filter, soft delete |
| Patients management | Full patient list with details |
| Guardians management | Guardian list with linked patients |
| Files & emergencies | Browse all, filter, delete |
| Audit log viewer | Searchable log explorer |

**Deliverable:** Admin can manage the entire platform.

#### Week 12 — Security, Testing & Deployment
| Task | Details |
|------|---------|
| Rate limiting | Configure on auth, SOS, file upload |
| Security audit | Validate encryption, permissions, data exposure |
| API testing | Feature tests for critical endpoints |
| Flutter testing | Widget tests for key screens |
| CI/CD setup | GitHub Actions / Laravel Forge |
| Production deployment | VPS / Laravel Forge + PostgreSQL + Supabase |
| App store preparation | Screenshots, descriptions, privacy policy |

**Deliverable:** MVP deployed and usable.

## Parallel Tasks (Throughout)

| Task | When |
|------|------|
| l10n setup (AR/EN) | Week 1 — add strings incrementally |
| Dark mode | Week 1 — theme setup, implement as you build |
| Glassmorphism components | Week 1 — build reusable components |
| Error handling | Continuous — standardize patterns |
| Loading states | Continuous — shimmer + loading overlay |

## Integration Milestones

| Integration | Week |
|-------------|------|
| Supabase Storage | Week 4 |
| Firebase (FCM) | Week 8 |
| Google Maps | Week 10 |

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Scope creep | Strict MVP scope. Use the "Excluded Features" list as a shield. |
| Solo dev burnout | 12 weeks is aggressive. If slipping, cut admin dashboard to basic CRUD. |
| Third-party API limits | Cache hospital data. Implement retry with backoff for FCM. |
| Encryption performance | Only encrypt sensitive text fields (diseases, allergies, medications). Not the whole DB. |
| Mobile platform differences | Test on both Android and iOS weekly. Use platform-aware code only when necessary. |
