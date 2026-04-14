# LCA Terraform — Project Context

## What This Is
Infrastructure as Code (Terraform) for the Amazon Transcribe Live Call Analytics platform.
The goal is to manage the LCA CloudFormation stacks via Terraform for better control, reproducibility, and cost management.

## AWS Account & Region
- Account: 025066253495
- Region: us-east-1
- AWS Profile: `lca` (configure with `aws configure --profile lca`)

## Current LCA Deployment (CloudFormation — what we're migrating from)
The LCA platform is currently deployed via nested CloudFormation stacks. Full analysis reports are in `docs/`.

### Required Stacks (KEEP — these power the live product)
1. **AISTACK** (LCA-AISTACK-SPFQARZ85S1Q) — Core: AppSync, DynamoDB, Cognito, S3, CloudFront
2. **WEBSOCKET** — Real-time audio streaming from agents' browsers
3. **WEBSOCKET-TRANSCRIBER** — Transcribes audio via Amazon Transcribe, writes to DynamoDB
4. **AGENTASSIST-SETUP** — Bedrock-powered call summaries and agent assist

### Safe to Delete (not used — see docs/LCA_Safe_Deletion_Explanation.txt)
- CHIMEVC, CONNECT-INTEGRATION, CONNECT-KVS, GENESYS, TALKDESK, WHISPER-SAGEMAKER, BEDROCKKB, VPC

## Key AWS Resources
- CloudFront: https://dna44ohv0ueyn.cloudfront.net (distribution: E1CO98XRGE0U7T)
- S3 bucket: lca-aistack-spfqarz85s1q-webappbucket-xarilravgfbq
- Cognito User Pool: us-east-1_2c7N4cvcO
- Cognito App Client: 4h3srt7vsn17qs9uj8m791cmgv
- Cognito Domain: tih-wellington-lca-qa.auth.us-east-1.amazoncognito.com
- AppSync API: ue2b3vkt2vhtnenm6q3t7tv62y.appsync-api.us-east-1.amazonaws.com/graphql
- Allowed email domain: crcgroup.com

## SSO Setup (already working)
- Auth flow: Microsoft Entra ID → Cognito Hosted UI → React app
- Amplify v4 with `federatedSignIn({ customProvider: 'EntraID' })`
- Email from `custom:email_alias` attribute
- NameID format in Azure: Persistent (critical)

## UI Build & Deploy (current — pre-Terraform)
```bash
cd ~/amazon-transcribe-live-call-analytics/lca-ai-stack/source/ui
NODE_OPTIONS=--max-old-space-size=1536 npm run build
aws s3 sync build/ s3://lca-aistack-spfqarz85s1q-webappbucket-xarilravgfbq --delete --profile lca
aws cloudfront create-invalidation --distribution-id E1CO98XRGE0U7T --paths "/*" --profile lca
```

## Reference
- `docs/` — Full CloudFormation stack analysis reports (resources, costs, what's safe to delete)
- `~/amazon-transcribe-live-call-analytics/` — Original LCA source code (CloudFormation + React UI)
- `~/LCA_*.txt` — Same analysis reports (also copied to docs/ for version control)
