#  Reselio – Business Management System

A full-stack monorepo for managing small reseller operations, inventory, and workflows.  
Includes a **NestJS backend** (`/apps/api`) and a **NextJS frontend** (`/apps/web`).

---

##  Problem Statement

Small online resellers often struggle to:

- Keep accurate inventory  
- Track orders and sales efficiently  
- Manage multiple product categories  
- Organize operations with a simple dashboard

**Reselio solves:**  
- Centralized inventory and product management  
- Streamlined order tracking  
- Dashboard for operational visibility  
- Full-stack solution with scalable architecture  

---

##  Project Goals

- Build a scalable monorepo with backend and frontend  
- Implement secure authentication and role-based access  
- Provide REST APIs for inventory, users, and orders  
- Build a responsive frontend dashboard  
- Showcase modern architecture with NestJS + NextJS  

---

##  Tech Stack

**Backend (`/apps/api`)**  
- NestJS  
- MongoDB  
- JWT Authentication  

**Frontend (`/apps/web`)**  
- NextJS 
- Tailwind CSS    

**Tools & Utilities**  
- Git & GitHub  
- Insomnia  
- ESLint, Prettier  
- TurboRepo Monorepo structure  

---

##  Core Features

- User authentication and authorization  
- Product and category CRUD operations  
- Inventory management  
- Order tracking  
- Dashboard with responsive design  

---

##  Installation Instructions

1. Clone the monorepo:

```bash
git clone https://github.com/mombeh/reselio.git
cd reselio
```

2. Install dependencies:

```bash
npm install
```

3. Copy `.env` files for backend and frontend:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
```

4. Run development servers:

**Backend:**
```bash
cd apps/api
npm run start:dev
```

**Frontend:**
```bash
cd apps/web
npm run dev
```

5. Visit `http://localhost:3000` (frontend)

---

## 🏗 Project Structure

```
reselio/
│
├── apps/
│   ├── api/          # NestJS backend
│   ├── web/          # React frontend
├── packages/
│   ├── ui/           # shared UI components
│   ├── typescript-config/
│   └── eslint-config/
├── node_modules/
├── package.json
└── turbo.json        # monorepo config
```

---

##  Challenges Faced

- Structuring a monorepo with `/apps/api` and `/apps/web`  
- JWT authentication and secure route handling  
- API integration and error handling  
