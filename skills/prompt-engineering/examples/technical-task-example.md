# Example: Technical Task (TIDD-EC Framework)

## Input Request

"Implement a caching layer for our item API endpoints to reduce database load"

## Framework Selection

**Selected: TIDD-EC** (technical task with clear constraints and specific implementation)

**Rationale:** This is a focused technical implementation with clear requirements, specific constraints, and needs precise execution guidance.

---

## Structured Output

# item API Caching Implementation

## Task Type
**Category:** Implementation (backend optimization)
**Complexity:** Moderate

## Instructions

1. **Analyze current API endpoints** for caching candidates
   - GET /items (list) - High cache potential
   - GET /items/{id} (detail) - High cache potential
   - POST/PUT/DELETE - Must invalidate cache

2. **Configure Redis caching layer**
   - Set up Redis connection in config
   - Create cache service wrapper
   - Define TTL strategy per endpoint

3. **Implement cache-aside pattern**
   - Check cache before DB query
   - Write to cache after DB query
   - Return cached response if valid

4. **Add cache invalidation**
   - Invalidate on item create/update/delete
   - Invalidate user-specific caches on profile change
   - Implement cache warming for popular items

5. **Add monitoring and metrics**
   - Cache hit/miss ratio
   - Cache size and memory usage
   - Response time comparison

## Do
- Use Redis with JSON serialization
- Set different TTLs: list (5 min), detail (15 min)
- Include cache headers in API responses (ETag, Cache-Control)
- Log cache operations for debugging
- Write unit tests for cache service

## Don't
- Don't cache authenticated user-specific data globally
- Don't cache POST/PUT/DELETE responses
- Don't use infinite TTL (always set expiration)
- Don't bypass cache invalidation on writes
- Don't cache error responses

## Examples

**Good: Cache key structure**
```python
# Namespace + resource + identifier
cache_key = f"${project_name}:items:list:{page}:{limit}"
cache_key = f"${project_name}:items:detail:{item_id}"
```

**Bad: Cache key structure**
```python
# Too generic, collision risk
cache_key = f"items_{id}"
```

**Good: Cache-aside implementation**
```python
async def get_item(item_id: str) -> item:
    # Check cache first
    cached = await redis.get(f"${project_name}:items:detail:{item_id}")
    if cached:
        return item.parse_raw(cached)

    # Cache miss: query DB
    item = await db.get_item(item_id)

    # Write to cache
    await redis.set(
        f"${project_name}:items:detail:{item_id}",
        item.json(),
        ex=900  # 15 minutes
    )

    return item
```

## Content

**Current endpoints to cache:**
- `GET /api/v1/items` - item list with pagination
- `GET /api/v1/items/{id}` - item detail
- `GET /api/v1/items/{id}/similar` - Similar items

**Invalidation triggers:**
- item created → Invalidate list cache
- item updated → Invalidate detail + list cache
- item deleted → Invalidate detail + list cache

---

## Validation Checklist

- [x] Task type clear (implementation, moderate complexity)
- [x] Instructions are numbered and specific (5 steps)
- [x] Do list has 5 required behaviors
- [x] Don't list has 5 prohibited behaviors
- [x] Good/bad examples provided with code
- [x] Content section provides input material
