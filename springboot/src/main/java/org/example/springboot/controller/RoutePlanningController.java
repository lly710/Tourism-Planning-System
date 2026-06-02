package org.example.springboot.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.example.springboot.common.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Tag(name = "Route Planning")
@RestController
@RequestMapping("/route")
public class RoutePlanningController {

    /** 路线规划控制器：
     *  1. 对外提供路线规划、地理编码、逆地理编码和 POI 搜索接口
     *  2. 根据前端选择的规划方式与规划目标，动态获取高德真实路网距离/时长
     *  3. 通过状态压缩动态规划（Held-Karp）计算闭环最优访问顺序
     */
    private static final Logger LOGGER = LoggerFactory.getLogger(RoutePlanningController.class);
    /** 第三方接口降级为直线距离时，用于估算步行时长的默认速度（米/秒） */
    private static final double WALKING_SPEED_METERS_PER_SECOND = 1.2;
    /** 第三方接口降级为直线距离时，用于估算驾车时长的默认速度（米/秒） */
    private static final double DRIVING_SPEED_METERS_PER_SECOND = 11.11;

    @Value("${amap.key}")
    private String amapKey;

    private final RestTemplate restTemplate = new RestTemplate();

    /** 同时承载两点之间的距离与时长，便于后续按不同规划目标构建比较矩阵 */
    private static class RouteMetric {
        final double distance;
        final double duration;

        RouteMetric(double distance, double duration) {
            this.distance = distance;
            this.duration = duration;
        }
    }

    /** 将前端传来的出行方式转换为高德距离矩阵接口所需的 type 参数 *如果 travelMode 是空值 null，默认返回 2* */

    private int resolveDistanceType(String travelMode) {
        if (travelMode == null) {
            return 2;
        }

        String normalized = travelMode.trim().toLowerCase(Locale.ROOT);
        if ("walk".equals(normalized) || "walking".equals(normalized) || "1".equals(normalized)) {
            return 1;
        }
        if ("line".equals(normalized) || "straight".equals(normalized) || "0".equals(normalized)) {
            return 0;
        }
        return 2;
    }

    /** 统一规范前端传来的出行方式，系统内部仅保留 car / walk 两种模式 */
    private String normalizeTravelMode(String travelMode) {
        if (travelMode == null) {
            return "car";
        }
        String normalized = travelMode.trim().toLowerCase(Locale.ROOT);
        return ("walk".equals(normalized) || "walking".equals(normalized)) ? "walk" : "car";
    }

    /** 统一规范规划目标，兼容前端与历史命名 */
    private String normalizePlanningStrategy(String planningStrategy) {
        if (planningStrategy == null) {
            return "distance";
        }
        String normalized = planningStrategy.trim().toLowerCase(Locale.ROOT);
        if ("distance_time".equals(normalized) || "distance-time".equals(normalized) || "distance_then_time".equals(normalized)) {
            return "distance_time";
        }
        if ("time_distance".equals(normalized) || "time-distance".equals(normalized) || "time_then_distance".equals(normalized)) {
            return "time_distance";
        }
        return "time".equals(normalized) ? "time" : "distance";
    }

    /** 驾车模式下，将系统中的规划目标映射为高德 driving 接口的 strategy 参数 */
    private int resolveDrivingStrategy(String planningStrategy) {
        String normalized = normalizePlanningStrategy(planningStrategy);
        return ("time".equals(normalized) || "time_distance".equals(normalized)) ? 0 : 2;
    }

    /** 获取驾车场景下两点之间的真实路网距离与时长，失败时退回到距离矩阵接口 */
    private RouteMetric getDrivingMetric(double[] from, double[] to, String planningStrategy) {
        try {
            int strategy = resolveDrivingStrategy(planningStrategy);
            String url = String.format(
                    "https://restapi.amap.com/v3/direction/driving?key=%s&origin=%s,%s&destination=%s,%s&strategy=%s&extensions=base&output=json",
                    amapKey, from[0], from[1], to[0], to[1], strategy
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                Map<?, ?> route = (Map<?, ?>) response.get("route");
                if (route != null) {
                    List<?> paths = (List<?>) route.get("paths");
                    if (paths != null && !paths.isEmpty()) {
                        Map<?, ?> path = (Map<?, ?>) paths.get(0);
                        Object distance = path.get("distance");
                        Object duration = path.get("duration");
                        if (distance != null && duration != null) {
                            return new RouteMetric(
                                    Double.parseDouble(distance.toString()),
                                    Double.parseDouble(duration.toString())
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.warn("Driving route request failed, fallback to matrix: {}", e.getMessage());
        }

        return getDistanceMatrixMetric(from, to, "car");
    }

    /** 获取步行场景下两点之间的真实路网距离与时长，失败时退回到距离矩阵接口 */
    private RouteMetric getWalkingMetric(double[] from, double[] to) {
        try {
            String url = String.format(
                    "https://restapi.amap.com/v3/direction/walking?key=%s&origin=%s,%s&destination=%s,%s&output=json",
                    amapKey, from[0], from[1], to[0], to[1]
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                Map<?, ?> route = (Map<?, ?>) response.get("route");
                if (route != null) {
                    List<?> paths = (List<?>) route.get("paths");
                    if (paths != null && !paths.isEmpty()) {
                        Map<?, ?> path = (Map<?, ?>) paths.get(0);
                        Object distance = path.get("distance");
                        Object duration = path.get("duration");
                        if (distance != null && duration != null) {
                            return new RouteMetric(
                                    Double.parseDouble(distance.toString()),
                                    Double.parseDouble(duration.toString())
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.warn("Walking route request failed, fallback to matrix: {}", e.getMessage());
        }

        return getDistanceMatrixMetric(from, to, "walk");
    }

    /** 使用高德距离矩阵接口兜底；若第三方继续失败，则再降级为 Haversine 直线距离估算 */
    private RouteMetric getDistanceMatrixMetric(double[] from, double[] to, String travelMode) {
        try {
            int distanceType = resolveDistanceType(travelMode);
            String url = String.format(
                    "https://restapi.amap.com/v3/distance?key=%s&origins=%s,%s&destination=%s,%s&type=%s",
                    amapKey, from[0], from[1], to[0], to[1], distanceType
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                List<?> results = (List<?>) response.get("results");
                if (results != null && !results.isEmpty()) {
                    Map<?, ?> result = (Map<?, ?>) results.get(0);
                    Object distance = result.get("distance");
                    Object duration = result.get("duration");
                    if (distance != null) {
                        return new RouteMetric(
                                Double.parseDouble(distance.toString()),
                                duration == null ? 0 : Double.parseDouble(duration.toString())
                        );
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.warn("Distance matrix request failed, fallback to straight distance: {}", e.getMessage());
        }

        double distance = haversine(from[1], from[0], to[1], to[0]);
        double duration = "walk".equalsIgnoreCase(travelMode)
                ? distance / WALKING_SPEED_METERS_PER_SECOND
                : distance / DRIVING_SPEED_METERS_PER_SECOND;
        return new RouteMetric(distance, duration);
    }

    /** 根据出行方式统一分发到驾车或步行的指标获取逻辑 */
    private RouteMetric getRouteMetric(double[] from, double[] to, String travelMode, String planningStrategy) {
        if ("walk".equals(normalizeTravelMode(travelMode))) {
            return getWalkingMetric(from, to);
        }
        return getDrivingMetric(from, to, planningStrategy);
    }

    /** Haversine 公式：在地图服务不可用时估算两点之间球面直线距离 */
    private double haversine(double lat1, double lng1, double lat2, double lng2) {
        final double earthRadius = 6371000;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    /** 经典状态压缩 TSP：
     *  仅按单一指标（距离或时间）进行比较，求解闭环最优顺序
     */
    private List<Integer> tspDP(double[][] dist) {
        int n = dist.length;
        int fullMask = (1 << n) - 1;
        double[][] dp = new double[1 << n][n];
        int[][] parent = new int[1 << n][n];

        for (double[] row : dp) {
            Arrays.fill(row, Double.MAX_VALUE / 2);
        }
        for (int[] row : parent) {
            Arrays.fill(row, -1);
        }

        dp[1][0] = 0;

        for (int mask = 1; mask <= fullMask; mask++) {
            for (int u = 0; u < n; u++) {
                if ((mask & (1 << u)) == 0) {
                    continue;
                }
                if (dp[mask][u] >= Double.MAX_VALUE / 2) {
                    continue;
                }

                for (int v = 0; v < n; v++) {
                    if ((mask & (1 << v)) != 0) {
                        continue;
                    }
                    int newMask = mask | (1 << v);
                    double newDist = dp[mask][u] + dist[u][v];
                    if (newDist < dp[newMask][v]) {
                        dp[newMask][v] = newDist;
                        parent[newMask][v] = u;
                    }
                }
            }
        }

        double best = Double.MAX_VALUE;
        int last = -1;
        for (int u = 1; u < n; u++) {
            double total = dp[fullMask][u] + dist[u][0];
            if (total < best) {
                best = total;
                last = u;
            }
        }

        List<Integer> path = new ArrayList<>();
        int mask = fullMask;
        int current = last;
        while (current != -1) {
            path.add(current);
            int prev = parent[mask][current];
            mask ^= (1 << current);
            current = prev;
        }
        Collections.reverse(path);
        return path;
    }

    /** 比较两个候选状态：
     *  先比较主指标，若主指标近似相等，再比较次指标
     */
    private boolean isBetter(double primaryA, double secondaryA, double primaryB, double secondaryB) {
        double epsilon = 1e-6;
        if (primaryA + epsilon < primaryB) {
            return true;
        }
        if (primaryB + epsilon < primaryA) {
            return false;
        }
        return secondaryA + epsilon < secondaryB;
    }

    /** 双层优先级版本：
     *  先按总时间最优，若总时间相同（或极接近），再按总距离最优
     */
    private List<Integer> tspDPByTimeThenDistance(double[][] duration, double[][] distance) {
        int n = duration.length;
        int fullMask = (1 << n) - 1;
        double[][] dpTime = new double[1 << n][n];
        double[][] dpDistance = new double[1 << n][n];
        int[][] parent = new int[1 << n][n];

        for (double[] row : dpTime) {
            Arrays.fill(row, Double.MAX_VALUE / 2);
        }
        for (double[] row : dpDistance) {
            Arrays.fill(row, Double.MAX_VALUE / 2);
        }
        for (int[] row : parent) {
            Arrays.fill(row, -1);
        }

        dpTime[1][0] = 0;
        dpDistance[1][0] = 0;

        for (int mask = 1; mask <= fullMask; mask++) {
            for (int u = 0; u < n; u++) {
                if ((mask & (1 << u)) == 0) {
                    continue;
                }
                if (dpTime[mask][u] >= Double.MAX_VALUE / 2) {
                    continue;
                }

                for (int v = 0; v < n; v++) {
                    if ((mask & (1 << v)) != 0) {
                        continue;
                    }

                    int newMask = mask | (1 << v);
                    double newTime = dpTime[mask][u] + duration[u][v];
                    double newDistance = dpDistance[mask][u] + distance[u][v];
                    if (isBetter(newTime, newDistance, dpTime[newMask][v], dpDistance[newMask][v])) {
                        dpTime[newMask][v] = newTime;
                        dpDistance[newMask][v] = newDistance;
                        parent[newMask][v] = u;
                    }
                }
            }
        }

        double bestTime = Double.MAX_VALUE;
        double bestDistance = Double.MAX_VALUE;
        int last = -1;
        for (int u = 1; u < n; u++) {
            double totalTime = dpTime[fullMask][u] + duration[u][0];
            double totalDistance = dpDistance[fullMask][u] + distance[u][0];
            if (isBetter(totalTime, totalDistance, bestTime, bestDistance)) {
                bestTime = totalTime;
                bestDistance = totalDistance;
                last = u;
            }
        }

        List<Integer> path = new ArrayList<>();
        int mask = fullMask;
        int current = last;
        while (current != -1) {
            path.add(current);
            int prev = parent[mask][current];
            mask ^= (1 << current);
            current = prev;
        }
        Collections.reverse(path);
        return path;
    }

    /** 双层优先级版本：
     *  先按总距离最优，若总距离相同（或极接近），再按总时间最优
     */
    private List<Integer> tspDPByDistanceThenTime(double[][] distance, double[][] duration) {
        int n = distance.length;
        int fullMask = (1 << n) - 1;
        double[][] dpDistance = new double[1 << n][n];
        double[][] dpTime = new double[1 << n][n];
        int[][] parent = new int[1 << n][n];

        for (double[] row : dpDistance) {
            Arrays.fill(row, Double.MAX_VALUE / 2);
        }
        for (double[] row : dpTime) {
            Arrays.fill(row, Double.MAX_VALUE / 2);
        }
        for (int[] row : parent) {
            Arrays.fill(row, -1);
        }

        dpDistance[1][0] = 0;
        dpTime[1][0] = 0;

        for (int mask = 1; mask <= fullMask; mask++) {
            for (int u = 0; u < n; u++) {
                if ((mask & (1 << u)) == 0) {
                    continue;
                }
                if (dpDistance[mask][u] >= Double.MAX_VALUE / 2) {
                    continue;
                }

                for (int v = 0; v < n; v++) {
                    if ((mask & (1 << v)) != 0) {
                        continue;
                    }

                    int newMask = mask | (1 << v);
                    double newDistance = dpDistance[mask][u] + distance[u][v];
                    double newTime = dpTime[mask][u] + duration[u][v];
                    if (isBetter(newDistance, newTime, dpDistance[newMask][v], dpTime[newMask][v])) {
                        dpDistance[newMask][v] = newDistance;
                        dpTime[newMask][v] = newTime;
                        parent[newMask][v] = u;
                    }
                }
            }
        }

        double bestDistance = Double.MAX_VALUE;
        double bestTime = Double.MAX_VALUE;
        int last = -1;
        for (int u = 1; u < n; u++) {
            double totalDistance = dpDistance[fullMask][u] + distance[u][0];
            double totalTime = dpTime[fullMask][u] + duration[u][0];
            if (isBetter(totalDistance, totalTime, bestDistance, bestTime)) {
                bestDistance = totalDistance;
                bestTime = totalTime;
                last = u;
            }
        }

        List<Integer> path = new ArrayList<>();
        int mask = fullMask;
        int current = last;
        while (current != -1) {
            path.add(current);
            int prev = parent[mask][current];
            mask ^= (1 << current);
            current = prev;
        }
        Collections.reverse(path);
        return path;
    }

    @Operation(summary = "按规划目标计算路线")
    @PostMapping("/plan")
    @SuppressWarnings("unchecked")
    public Result<?> planRoute(@RequestBody Map<String, Object> body) {
        try {
            // 前端传入的地点集合，默认约定第一个点为起点
            List<Map<String, Object>> places = (List<Map<String, Object>>) body.get("places");
            // 规划方式：car / walk
            String travelMode = normalizeTravelMode(body.get("travelMode") == null ? "car" : String.valueOf(body.get("travelMode")));
            // 规划目标：distance / time / time_distance / distance_time
            String planningStrategy = normalizePlanningStrategy(
                    body.get("planningStrategy") == null ? "distance" : String.valueOf(body.get("planningStrategy"))
            );

            if (places == null || places.size() < 2) {
                return Result.error("At least 2 places are required");
            }
            if (places.size() > 10) {
                return Result.error("At most 10 places are supported");
            }

            int n = places.size();
            double[][] coords = new double[n][2];
            for (int i = 0; i < n; i++) {
                Map<String, Object> place = places.get(i);
                coords[i][0] = Double.parseDouble(place.get("lng").toString());
                coords[i][1] = Double.parseDouble(place.get("lat").toString());
            }

            // 预先构建距离矩阵、时长矩阵和当前规划目标对应的 cost 矩阵
            double[][] distMatrix = new double[n][n];
            double[][] durationMatrix = new double[n][n];
            double[][] costMatrix = new double[n][n];
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    if (i == j) {
                        continue;
                    }

                    RouteMetric metric = getRouteMetric(coords[i], coords[j], travelMode, planningStrategy);
                    distMatrix[i][j] = metric.distance;
                    durationMatrix[i][j] = metric.duration;
                    costMatrix[i][j] = "time".equals(planningStrategy) ? metric.duration : metric.distance;
                }
            }

            // 根据规划目标选择不同的动态规划比较逻辑
            List<Integer> order;
            if (n == 2) {
                order = Arrays.asList(0, 1);
            } else if ("time_distance".equals(planningStrategy)) {
                order = tspDPByTimeThenDistance(durationMatrix, distMatrix);
            } else if ("distance_time".equals(planningStrategy)) {
                order = tspDPByDistanceThenTime(distMatrix, durationMatrix);
            } else {
                order = tspDP(costMatrix);
            }

            // 按求得的访问顺序累计闭环总距离、总时长和总成本
            double totalDistance = 0;
            double totalDuration = 0;
            double totalCost = 0;
            for (int i = 0; i < order.size() - 1; i++) {
                int from = order.get(i);
                int to = order.get(i + 1);
                totalDistance += distMatrix[from][to];
                totalDuration += durationMatrix[from][to];
                totalCost += costMatrix[from][to];
            }
            if (order.size() > 1) {
                int last = order.get(order.size() - 1);
                int first = order.get(0);
                totalDistance += distMatrix[last][first];
                totalDuration += durationMatrix[last][first];
                totalCost += costMatrix[last][first];
            }

            List<Map<String, Object>> orderedPlaces = new ArrayList<>();
            for (Integer idx : order) {
                orderedPlaces.add(places.get(idx));
            }
            orderedPlaces.add(places.get(order.get(0)));

            // 返回前端所需的完整结果，便于地图渲染、分段导航和统计展示
            Map<String, Object> result = new HashMap<>();
            result.put("order", order);
            result.put("orderedPlaces", orderedPlaces);
            result.put("totalDistance", Math.round(totalDistance));
            result.put("totalDuration", Math.round(totalDuration));
            result.put("totalCost", Math.round(totalCost));
            result.put("distMatrix", distMatrix);
            result.put("durationMatrix", durationMatrix);
            result.put("costMatrix", costMatrix);
            result.put("travelMode", travelMode);
            result.put("planningStrategy", planningStrategy);

            return Result.success(result);
        } catch (Exception e) {
            LOGGER.error("Route planning failed", e);
            return Result.error("Route planning failed: " + e.getMessage());
        }
    }

    @Operation(summary = "地址转经纬度")
    @GetMapping("/geocode")
    public Result<?> geocode(@RequestParam String address) {
        try {
            // 地址转经纬度：供搜索地点、补全地点坐标等场景使用
            String url = String.format(
                    "https://restapi.amap.com/v3/geocode/geo?key=%s&address=%s&output=json",
                    amapKey, URLEncoder.encode(address, StandardCharsets.UTF_8)
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                List<?> geocodes = (List<?>) response.get("geocodes");
                if (geocodes != null && !geocodes.isEmpty()) {
                    Map<?, ?> geo = (Map<?, ?>) geocodes.get(0);
                    String location = String.valueOf(geo.get("location"));
                    String[] parts = location.split(",");
                    if (parts.length >= 2) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("lng", Double.parseDouble(parts[0]));
                        data.put("lat", Double.parseDouble(parts[1]));
                        data.put("address", geo.get("formatted_address"));
                        return Result.success(data);
                    }
                }
            }
            return Result.error("Address not found");
        } catch (Exception e) {
            LOGGER.error("Geocode failed", e);
            return Result.error("Geocode failed: " + e.getMessage());
        }
    }

    @Operation(summary = "经纬度逆解析地址")
    @GetMapping("/regeo")
    public Result<?> regeo(@RequestParam double lng, @RequestParam double lat) {
        try {
            // 经纬度转地点名称：供地图点选后自动识别地点名称使用
            String url = String.format(
                    "https://restapi.amap.com/v3/geocode/regeo?key=%s&location=%s,%s&radius=200&extensions=all&output=json",
                    amapKey, lng, lat
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                Map<?, ?> regeocode = (Map<?, ?>) response.get("regeocode");
                if (regeocode != null) {
                    String name = null;

                    List<?> pois = (List<?>) regeocode.get("pois");
                    if (pois != null && !pois.isEmpty()) {
                        Map<?, ?> poi = (Map<?, ?>) pois.get(0);
                        name = (String) poi.get("name");
                    }

                    if (name == null || name.isEmpty()) {
                        Map<?, ?> addressComponent = (Map<?, ?>) regeocode.get("addressComponent");
                        if (addressComponent != null) {
                            String streetName = addressComponent.get("street") instanceof String ? (String) addressComponent.get("street") : "";
                            String township = addressComponent.get("township") instanceof String ? (String) addressComponent.get("township") : "";
                            String district = addressComponent.get("district") instanceof String ? (String) addressComponent.get("district") : "";
                            String number = "";

                            if (addressComponent.get("streetNumber") instanceof Map) {
                                Object numObj = ((Map<?, ?>) addressComponent.get("streetNumber")).get("number");
                                if (numObj instanceof String && !((String) numObj).isEmpty()) {
                                    number = (String) numObj;
                                }
                            }

                            if (!streetName.isEmpty()) {
                                name = streetName + (number.isEmpty() ? "" : number);
                            } else if (!township.isEmpty()) {
                                name = township;
                            } else if (!district.isEmpty()) {
                                name = district;
                            }
                        }
                    }

                    if (name == null || name.isEmpty()) {
                        name = (String) regeocode.get("formatted_address");
                    }

                    Map<String, Object> result = new HashMap<>();
                    result.put("name", name != null ? name : String.format("Location(%.4f,%.4f)", lng, lat));
                    return Result.success(result);
                }
            }
        } catch (Exception e) {
            LOGGER.error("Reverse geocode failed", e);
        }

        Map<String, Object> fallback = new HashMap<>();
        fallback.put("name", String.format("Location(%.4f,%.4f)", lng, lat));
        return Result.success(fallback);
    }

    @Operation(summary = "搜索 POI 地点")
    @GetMapping("/search")
    public Result<?> searchPoi(@RequestParam String keywords) {
        try {
            // POI 搜索：供前端地点联想搜索与地点添加使用
            String url = String.format(
                    "https://restapi.amap.com/v3/place/text?key=%s&keywords=%s&region=%s&citylimit=false&offset=10&page=1&extensions=base&output=json",
                    amapKey,
                    URLEncoder.encode(keywords, StandardCharsets.UTF_8),
                    URLEncoder.encode("China", StandardCharsets.UTF_8)
            );
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null && "1".equals(String.valueOf(response.get("status")))) {
                List<?> pois = (List<?>) response.get("pois");
                if (pois != null && !pois.isEmpty()) {
                    List<Map<String, Object>> result = new ArrayList<>();
                    for (Object obj : pois) {
                        Map<?, ?> poi = (Map<?, ?>) obj;
                        Object locationObj = poi.get("location");
                        if (locationObj == null) {
                            continue;
                        }

                        String location = String.valueOf(locationObj);
                        if (location.isEmpty() || !location.contains(",")) {
                            continue;
                        }

                        String[] parts = location.split(",");
                        if (parts.length < 2) {
                            continue;
                        }

                        try {
                            Map<String, Object> item = new HashMap<>();
                            item.put("name", poi.get("name"));
                            item.put("address", poi.get("address"));
                            item.put("cityname", poi.get("cityname"));
                            item.put("adname", poi.get("adname"));
                            item.put("pname", poi.get("pname"));
                            item.put("lng", Double.parseDouble(parts[0]));
                            item.put("lat", Double.parseDouble(parts[1]));
                            result.add(item);
                        } catch (NumberFormatException ignore) {
                            // ignore invalid poi
                        }
                    }
                    return Result.success(result);
                }
            }
            return Result.success(new ArrayList<>());
        } catch (Exception e) {
            LOGGER.error("Search POI failed", e);
            return Result.error("Search POI failed: " + e.getMessage());
        }
    }
}
