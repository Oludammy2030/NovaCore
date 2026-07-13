# Deploy Nexus on Hostinger VPS — Complete Guide

No technical background required. Follow each step in order.
Total time: about 15–20 minutes.

---

## What You Need Before Starting

- A Hostinger account ([hostinger.com](https://hostinger.com))
- A Telegram account
- A GitHub account (free)
- A Supabase account (free)
- A Google account
- Credit card for Hostinger VPS (~+$4–6/month)

---

## Step 1 — Buy Hostinger KVM 1 VPS

1. Go to [hostinger.com/vps-hosting](https://hostinger.com/vps-hosting)
2. Choose **KVM 1** (~$4–6/month)
3. OS Selection: **Ubuntu 22.04**
4. Complete purchase - wait 2–3 minutes

---

## Step 2 — Connect to Your VPS

**Windows**: Download [PuTTY](https://putty.org) — enter VPS IP → login as root

**Mac/Linux**: `ssh root@YOUR_VPS_IP`

---

## Step 3 — Run the Installer

In your VPS terminal, paste this **one command**:

```bash
curl -fsSL https://raw.githubusercontent.com/Oludammy2030/afrinova-app/main/install.sh | bash
```

The script asks:
1. Domain type: `1` (own domain) or `2` (free DuckDNS)
2. Your domain name
3. n8n admin email + password

Installs everything automatically (~3 minutes).

---

## Step 4 — Set Up Supabase

1. [supabase.com](https://supabase.com) — create free account — new project
2. SQL Editor — copy and run `setup.sql` from this repo
3. Settings → Database → Connection Pooler → copy Session mode URI

---

## Step 5 — Import & Configure

1. Open `https://YOUR_DOMAIN` in browser, log in
2. Settings → API → Create API Key
3. Settings → Import/Export → import workflow JSONs from this repo
4. Open: `https://YOUR_DOMAIN/form/ai-suite-setup`
5. Fill in all fields - submit - wizard configures everything

---

## Step 6 — Connect Credentials (Manual)

In n8n — Credentials → Add Credential:

| Credential | Type | Source |
|-----------|------|--------|
| Telegram Bot | Telegram API | @BotFather on Telegram |
| Gemini AI | Google PaLM API | aistudio.google.com/app/apikey |
| Google Drive | Google Drive OAuth2 | Google Cloud Console |
| Google Docs | Google Docs OAuth2 | Same Google project |
| GitHub OAuth | GitHub OAuth2 | GitHub Dev Settings |
| GitHub PAT | HTTP Bearer Auth | GitHub Personal Access Tokens |
| PostgreSQL | PostgreSQL | Supabase connection string |
| Groq (voice) | Groq API | console.groq.com/keys (free) |

---

## Step 7 — Publish In Order

1. Error Monitor (first always)
2. Document Generator, Cursor Spec Handoff, Issue Verifier
3. Project Memory, Agent Dispatcher, Job History, Job Status
\u20234. Specialist agents (Insight, Forge, Sentinel)
5. Core Agent (last main workflow)
6. Scheduled workflows (Knowledge Ingestion, Weekly Report, etc.)
7. PR Reviewer (last — registers GitHub webhook)

---

## Test

Send `/start` to your Telegram bot. You should get the welcome message.

---

## Monthly Cost

| Item | Cost |
|------|------|
| Hostinger KVM 1 | ~$4–6/month |
| Domain (optional) | ~$1/month or free (DuckDNS) |
| Supabase | Free tier |
| Gemini | Free quota |
| **Total** | **~$5–7/month** |

---

*AfriNova Nexus — AI Engineering Executive Built with n8n Self-hosted on Hostinger*
