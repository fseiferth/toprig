# Architecture: ${FEATURE_NAME}

**Feature ID:** ${FEATURE_ID}
**Architect:** [Name]
**Status:** Draft | In Review | Approved
**PRD:** [Link] | **Design:** [Link]

## Overview

Brief description of the architectural approach.

## API Contracts

### [Endpoint Name]
```
METHOD /api/v1/resource
```
**Purpose:** 
**Auth:** Required/Optional
**Request Body:**
```json
{}
```
**Response (200):**
```json
{}
```
**Error Responses:** 400, 401, 404, 500

## Data Model

### [Table/Collection Name]
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK | |
| created_at | timestamp | NOT NULL | |

## Sequence Diagram

```
Client → API → Service → Database
```

## Security Considerations

- Authentication: 
- Authorization: 
- Data validation: 
- Rate limiting: 

## Performance Requirements

| Metric | Target |
|--------|--------|
| Response time (p95) | |
| Throughput | |
| Data volume | |

## Migration Plan

- [ ] Schema migration script
- [ ] Data migration (if needed)
- [ ] Rollback procedure documented

## Dependencies

| Service | Why | Fallback |
|---------|-----|----------|
| | | |
