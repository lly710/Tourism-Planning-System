const ROUTE_MARKER_PREFIX = '<!-- GUIDE_ROUTE:'
const ROUTE_MARKER_SUFFIX = '-->'

function safeBtoa(str) {
  return window.btoa(unescape(encodeURIComponent(str)))
}

function safeAtob(str) {
  return decodeURIComponent(escape(window.atob(str)))
}

export function normalizeRoutePlaces(places) {
  if (!Array.isArray(places)) return []

  return places
    .map((item, index) => ({
      id: item?.id ?? `${Date.now()}_${index}`,
      name: String(item?.name || '').trim(),
      lng: Number(item?.lng),
      lat: Number(item?.lat)
    }))
    .filter((item) => item.name && Number.isFinite(item.lng) && Number.isFinite(item.lat))
}

export function stripGuideRouteMarker(content = '') {
  return content.replace(/<!--\s*GUIDE_ROUTE:[\s\S]*?-->/g, '').trim()
}

export function embedGuideRoute(content = '', routePlaces = []) {
  const cleanContent = stripGuideRouteMarker(content)
  const normalized = normalizeRoutePlaces(routePlaces)

  if (!normalized.length) {
    return cleanContent
  }

  const encoded = safeBtoa(JSON.stringify(normalized))
  return `${cleanContent}\n${ROUTE_MARKER_PREFIX}${encoded}${ROUTE_MARKER_SUFFIX}`.trim()
}

export function extractGuideRoute(content = '') {
  const match = content.match(/<!--\s*GUIDE_ROUTE:([\s\S]*?)-->/)
  if (!match?.[1]) {
    return []
  }

  try {
    const decoded = safeAtob(match[1].trim())
    return normalizeRoutePlaces(JSON.parse(decoded))
  } catch (error) {
    console.error('解析攻略路线失败:', error)
    return []
  }
}

export function encodeRouteForQuery(routePlaces = []) {
  const normalized = normalizeRoutePlaces(routePlaces)
  if (!normalized.length) return ''
  return encodeURIComponent(safeBtoa(JSON.stringify(normalized)))
}

export function decodeRouteFromQuery(value = '') {
  if (!value) return []

  try {
    const decoded = safeAtob(decodeURIComponent(value))
    return normalizeRoutePlaces(JSON.parse(decoded))
  } catch (error) {
    console.error('解析路由中的路线失败:', error)
    return []
  }
}
