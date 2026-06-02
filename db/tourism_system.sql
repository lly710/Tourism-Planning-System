-- MySQL dump 10.13  Distrib 9.0.1, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: tourism_system
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accommodation`
--

DROP TABLE IF EXISTS `accommodation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accommodation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰掑簵/姘戝/瀹㈡爤绛?,
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `scenic_id` bigint DEFAULT NULL COMMENT '鍏宠仈鏅偣ID',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `price_range` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '浠锋牸鍖洪棿',
  `star_level` decimal(2,1) DEFAULT NULL COMMENT '璇勫垎',
  `image_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `features` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐗硅壊鏈嶅姟',
  `distance` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璺濇櫙鐐硅窛绂?,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `scenic_id` (`scenic_id`) USING BTREE,
  CONSTRAINT `accommodation_ibfk_1` FOREIGN KEY (`scenic_id`) REFERENCES `scenic_spot` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accommodation`
--

LOCK TABLES `accommodation` WRITE;
/*!40000 ALTER TABLE `accommodation` DISABLE KEYS */;
INSERT INTO `accommodation` VALUES (1,'绱鍩庣殗瀹堕厭搴?,'閰掑簵','鍖椾含甯備笢鍩庡尯鏅北鍓嶈8鍙?,1,'绱鍩庣殗瀹堕厭搴椾綅浜庢晠瀹崥鐗╅櫌涓滀晶锛屾槸涓€瀹朵簲鏄熺骇璞崕閰掑簵銆傞厭搴楄璁¤瀺鍚堜簡涓浗浼犵粺鐨囧椋庢牸涓庣幇浠ｅア鍗庡厓绱狅紝涓哄瀹㈡彁渚涙瀬鑷寸殑浣忓浣撻獙銆?,'010-66180808','1200-3800',4.9,'/img/1748616500926.jpg','鍏嶈垂WiFi,24灏忔椂鍓嶅彴,瀹ゅ唴娓告吵姹?鍋ヨ韩涓績,涓タ椁愬巺','500绫?,'2025-05-30 17:50:11','2025-05-30 17:50:11'),(2,'鍖椾含鍥涘悎闄㈡皯瀹?,'姘戝','鍖椾含甯備笢鍩庡尯浜ら亾鍙ｅ崡澶ц45鍙?,1,'浼犵粺鍖椾含鍥涘悎闄㈡敼閫犵殑绮惧搧姘戝锛屼繚鐣欎簡鑰佸寳浜殑寤虹瓚鐗硅壊鍜屾枃鍖栭煹鍛筹紝姣忎釜鎴块棿閮芥湁涓嶅悓涓婚锛屼綋楠屼含鍩庤€佸懗閬撱€?,'010-65128765','680-1280',4.6,'/img/1748616665832.jpg','鍏嶈垂鏃╅,浼犵粺鑼惰壓浣撻獙,鍥涘悎闄㈡枃鍖栬瑙?鑷杞︾璧?,'1.2鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(3,'鏁呭闈掑勾鏃呰垗','闈掓梾','鍖椾含甯備笢鍩庡尯浜斿洓澶ц12鍙?,1,'浣嶄簬鏁呭闄勮繎鐨勭粡娴庡疄鎯犻潚骞存梾鑸嶏紝骞插噣鏁存磥锛屾槸鑳屽寘瀹㈠拰骞磋交娓稿鐨勭悊鎯抽€夋嫨銆傛彁渚涘浜洪棿鍜岀嫭绔嬫埧闂撮€夋嫨銆?,'010-65223366','120-380',4.2,'/img/1754195584989.jpg','鍏叡鍘ㄦ埧,琛屾潕瀵勫瓨,鍏嶈垂甯傚尯鍦板浘,鏃呮父鍜ㄨ鏈嶅姟','1.5鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(4,'闀垮煄鑴氫笅鐨勫叕绀?,'搴﹀亣鏉?,'鍖椾含甯傛€€鏌斿尯鎱曠敯宄暱鍩庢櫙鍖洪檮杩?,2,'鍧愯惤浜庢厱鐢板唱闀垮煄鑴氫笅鐨勫害鍋囨潙锛岀敱搴熷純灏忓鏀瑰缓鑰屾垚锛屼繚鐣欎簡鍘熸湁寤虹瓚椋庢牸锛岃瀺鍏ョ幇浠ｈ璁″厓绱狅紝鎻愪緵鐙壒鐨勪綇瀹夸綋楠屻€?,'010-61626688','1580-2980',4.5,'/img/1748616775441.jpg','瑙傛櫙闇插彴,鐗硅壊椁愬巺,鍏嶈垂鎺ラ€侀暱鍩庢湇鍔?鏂囧寲浣撻獙娲诲姩','1鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(5,'闀垮煄瀹㈡爤','瀹㈡爤','鍖椾含甯傛€€鏌斿尯姘撮暱鍩庤矾18鍙?,2,'浼犵粺鍖楁柟椋庢牸鐨勫啘瀹跺鏍堬紝鐑儏濂藉鐨勪富浜猴紝鍦伴亾鐨勫寳鏂瑰啘瀹惰彍锛岃鎮ㄥ湪闀垮煄鑴氫笅鎰熷彈娣虫湸鐨勬皯椋庛€?,'010-61618899','450-680',4.3,'/img/1754195486369.jpg','鍐滃楗?鐑х儰,鍏嶈垂鍋滆溅,鐧婚暱鍩庡悜瀵兼湇鍔?,'800绫?,'2025-05-30 17:50:11','2025-05-30 17:50:11'),(6,'闀垮煄灞辨按姘戝','姘戝','鍖椾含甯傛€€鏌斿尯鎱曠敯宄潙56鍙?,2,'渚濆北鑰屽缓鐨勭壒鑹叉皯瀹匡紝姣忎釜鎴块棿閮借兘娆ｈ祻鍒伴暱鍩庣編鏅紝瑁呬慨鍏搁泤娓╅Θ锛岃瀺鍏ュ綋鍦版枃鍖栧厓绱犮€?,'010-61657788','780-1380',4.7,'/img/1748616557730.jpg','瑙傛櫙闃冲彴,鎵嬪伐鑹鸿绋?闀垮煄鎽勫奖鎸囧,閲囨憳浣撻獙','1.5鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(7,'瑗挎箹闆呭洯閰掑簵','閰掑簵','娴欐睙鐪佹澀宸炲競瑗挎箹鍖烘潹鍏牑28鍙?,3,'浣嶄簬鏉ㄥ叕鍫ょ殑楂樻。閰掑簵锛岃惤鍦扮獥鍙洿鎺ヨ璧忚タ婀栫編鏅紝涓紡搴櫌璁捐锛岀粨鍚堢幇浠ｈ鏂斤紝灏芥樉姹熷崡闆呰嚧銆?,'0571-87982233','1080-2580',4.8,'/img/1748616523565.jpg','婀栨櫙鎴?绉佸鑺卞洯,涓紡涓嬪崍鑼?娓歌埞鏈嶅姟,鍋ヨ韩鎴?,'200绫?,'2025-05-30 17:50:11','2025-05-30 17:50:11'),(8,'瑗挎箹杈圭殑闄㈠瓙','姘戝','娴欐睙鐪佹澀宸炲競瑗挎箹鍖烘弧瑙夐檱璺?20鍙?,3,'浣嶄簬婊¤闄囩殑姹熷崡椋庢牸姘戝锛屽皬妗ユ祦姘达紝绔规灄鐜粫锛屽畨闈欓泤鑷达紝閫傚悎鏀炬澗韬績銆?,'0571-86546789','680-1280',4.7,'/img/1748616596201.jpg','鑼跺,鍙ょ惔婕斿,鎻掕姳璇剧▼,绉佸鍘ㄥ笀,鑷杞︾璧?,'500绫?,'2025-05-30 17:50:11','2025-05-30 17:50:11'),(9,'婀栫晹闈掑勾鏃呰垗','闈掓梾','娴欐睙鐪佹澀宸炲競瑗挎箹鍖哄寳灞辫84鍙?,3,'涓存箹鑰屽缓鐨勬枃鑹洪潚鏃咃紝涔﹂姘旀伅娴撳帤锛岃仛闆嗕簡鍚勫湴鏂囪壓闈掑勾锛屽父鏈夎涔︿細銆侀煶涔愬垎浜瓑娲诲姩銆?,'0571-85234567','120-350',4.4,'/img/1754195437050.jpg','鍏变韩鍥句功瑙?闊充箰瑙掕惤,鍏叡鍘ㄦ埧,鑷姪娲楄。鎴?鍏嶈垂WiFi','800绫?,'2025-05-30 17:50:11','2025-05-30 17:50:11'),(10,'榛勫北鎮︽搴?,'閰掑簵','瀹夊窘鐪侀粍灞卞競榛勫北鍖烘俯娉夐晣姹ゅ彛闀囨柊寤轰腑璺?8鍙?,4,'铻嶅悎寰芥淳寤虹瓚椋庢牸涓庣幇浠ｅア鍗庣殑搴﹀亣閰掑簵锛屾彁渚涙瀬鑷翠綇瀹夸綋楠岋紝鎷ユ湁娓╂硥SPA鍜屽绉嶄紤闂茶鏂姐€?,'0559-5586888','1680-5800',4.9,'/img/1748616463211.jpg','绉佷汉娓╂硥,寰芥淳椁愬巺,榛勫北瑙傛櫙鍙?鎴峰娉虫睜,SPA涓績,鍏嶈垂鐧诲北鍚戝','3鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(11,'鑰佽瀹㈡爤','瀹㈡爤','瀹夊窘鐪侀粍灞卞競榛勫北鍖烘堡鍙ｉ晣鑰佽45鍙?,4,'浣嶄簬姹ゅ彛鍙ら晣鑰佽鐨勪紶缁熷窘娲惧鏍堬紝鏈ㄨ川缁撴瀯锛岄洉鑺辩獥妫傦紝鍏呮弧鍘嗗彶闊靛懗锛屾彁渚涙俯棣ㄨ垝閫傜殑浣忓鐜銆?,'0559-5581234','380-680',4.5,'/img/1748616804380.jpg','寰芥淳鏃╅,鍙ゆ硶娉¤尪,鐧诲北鐗╄祫绉熻祦,鏃呮父鍜ㄨ,鎺ョ珯鏈嶅姟','4.5鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(12,'浜戠灏忛櫌','姘戝','瀹夊窘鐪侀粍灞卞競榛勫北鍖洪粺鍘胯タ閫掓潙78鍙?,4,'鍧愯惤浜庨粺鍘胯タ閫掓潙鐨勪紶缁熷窘娲炬皯灞咃紝灏忛櫌骞介潤锛岀鏋楃幆鎶憋紝杩滅鍠у殻锛屽敖浜北闂村畞闈欍€?,'0559-5156677','580-980',4.6,'/img/1748616728373.jpg','寰藉窞鑿滅鎴胯彍,鎵嬪伐鑹鸿绋?鍏嶈垂鐝溅,鑼跺,鍖荤枟鍖?,'15鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(13,'婕撴睙灞辨按闂撮厭搴?,'閰掑簵','骞胯タ澹棌鑷不鍖烘鏋楀競闃虫湐鍘块槼鏈旇タ琛?3鍙?,5,'浣嶄簬闃虫湐瑗胯鐨勭簿鍝侀厭搴楋紝渚濇睙鑰屽缓锛屽鎴块槼鍙扮洿闈㈡紦姹熺編鏅紝鐜颁唬涓紡瑁呬慨锛岃垝閫傚吀闆呫€?,'0773-8821888','880-1980',4.7,'/img/1748616638950.jpg','婕撴睙鏅鎴?鎴峰娉虫睜,涓タ鑷姪鏃╅,鍏嶈垂鑷杞?涔愬櫒婕斿','1鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(14,'闃虫湐鐢板洯鍐滆垗','姘戝','骞胯タ澹棌鑷不鍖烘鏋楀競闃虫湐鍘块珮鐢伴晣鍏村潽鍙ら晣56鍙?,5,'浣嶄簬鍏村潽鍙ら晣鐨勭壒鑹叉皯瀹匡紝鍥涘懆鏄箍琚ょ殑鐢伴噹鍜屽．瑙傜殑鍠€鏂壒鍦拌矊锛岃繙绂诲煄甯傚枾鍤ｏ紝鍥炲綊鑷劧鐢熸椿銆?,'0773-8786543','450-780',4.5,'/img/1754195358220.jpg','鍐滃楗?鏋滃洯閲囨憳,閽撻奔,绡濈伀鏅氫細,姘戞棌姝岃垶琛ㄦ紨','5鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11'),(15,'妗傛灄闈掕垗','闈掓梾','骞胯タ澹棌鑷不鍖烘鏋楀競璞″北鍖烘闃宠矾6鍙?,5,'浣嶄簬妗傛灄甯備腑蹇冪殑鐜颁唬鍖栭潚骞存梾鑸嶏紝浜ら€氫究鍒╋紝璁炬柦榻愬叏锛屾槸鑳屽寘瀹㈠拰鑷敱琛屾父瀹㈢殑鐞嗘兂閫夋嫨銆?,'0773-2825678','100-300',4.3,'/img/1754195521489.jpg','鍏嶈垂鏃╅,鏃呮父淇℃伅鍜ㄨ,琛屾潕瀵勫瓨,娲楄。鏈嶅姟,鍏变韩鍘ㄦ埧','3鍏噷','2025-05-30 17:50:11','2025-05-30 17:50:11');
/*!40000 ALTER TABLE `accommodation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accommodation_booking`
--

DROP TABLE IF EXISTS `accommodation_booking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accommodation_booking` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璁㈠崟缂栧彿',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `accommodation_id` bigint NOT NULL COMMENT '浣忓ID',
  `room_type_id` bigint NOT NULL COMMENT '鎴垮瀷ID',
  `check_in_date` date NOT NULL COMMENT '鍏ヤ綇鏃ユ湡',
  `check_out_date` date NOT NULL COMMENT '绂诲簵鏃ユ湡',
  `nights` int GENERATED ALWAYS AS ((to_days(`check_out_date`) - to_days(`check_in_date`))) STORED COMMENT '鍏ヤ綇鏅氭暟锛堣嚜鍔ㄨ绠楋級',
  `rooms` int NOT NULL DEFAULT '1' COMMENT '棰勮鎴块棿鏁伴噺',
  `guest_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏ヤ綇浜哄鍚?,
  `guest_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏ヤ綇浜烘墜鏈哄彿',
  `id_card` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '韬唤璇佸彿',
  `total_amount` decimal(10,2) NOT NULL COMMENT '璁㈠崟鎬婚噾棰?,
  `status` tinyint DEFAULT '0' COMMENT '璁㈠崟鐘舵€侊細0-寰呮敮浠橈紝1-宸叉敮浠橈紝2-宸插彇娑堬紝3-宸查€€娆撅紝4-宸插畬鎴?,
  `payment_time` datetime DEFAULT NULL COMMENT '鏀粯鏃堕棿',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏀粯鏂瑰紡锛氭敮浠樺疂/寰俊/閾惰鍗?,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞/鐗规畩瑕佹眰',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_order_no` (`order_no`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_accommodation_id` (`accommodation_id`) USING BTREE,
  KEY `idx_room_type_id` (`room_type_id`) USING BTREE,
  KEY `idx_date_range` (`check_in_date`,`check_out_date`) USING BTREE,
  CONSTRAINT `fk_booking_accommodation` FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_booking_room_type` FOREIGN KEY (`room_type_id`) REFERENCES `accommodation_room_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_booking_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='浣忓璁㈠崟琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accommodation_booking`
--

LOCK TABLES `accommodation_booking` WRITE;
/*!40000 ALTER TABLE `accommodation_booking` DISABLE KEYS */;
/*!40000 ALTER TABLE `accommodation_booking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accommodation_review`
--

DROP TABLE IF EXISTS `accommodation_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accommodation_review` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `accommodation_id` bigint DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `rating` decimal(2,1) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `accommodation_id` (`accommodation_id`) USING BTREE,
  CONSTRAINT `accommodation_review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `accommodation_review_ibfk_2` FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accommodation_review`
--

LOCK TABLES `accommodation_review` WRITE;
/*!40000 ALTER TABLE `accommodation_review` DISABLE KEYS */;
INSERT INTO `accommodation_review` VALUES (1,2,1,'閰掑簵鐜浼橀泤锛屾湇鍔″懆鍒帮紝璺濈鏁呭姝ヨ鍙渶鍑犲垎閽燂紝鍦扮悊浣嶇疆闈炲父濂斤紒鎴块棿瀹芥暈鏄庝寒锛屼腑寮忚淇緢鏈夌壒鑹诧紝鏃╅绉嶇被涓板瘜锛屼綋楠屾劅鏋佷匠銆?,5.0,'2025-05-15 10:30:00'),(2,3,1,'鎴块棿骞插噣鏁存磥锛屽墠鍙版湇鍔＄儹鎯呬笓涓氾紝鍞竴涓嶈冻鏄环鏍肩◢楂橈紝浣嗚€冭檻鍒板湴鐞嗕綅缃拰鏈嶅姟璐ㄩ噺锛岃繕鏄緢鍊煎緱鐨勩€?,4.5,'2025-05-16 14:20:00'),(3,4,1,'浣忓浣撻獙寰堝ソ锛屽挨鍏跺枩娆㈤厭搴楃殑涓紡椋庢牸璁捐锛屼笌鏁呭鐨勬枃鍖栨皼鍥寸浉寰楃泭褰般€傛吵姹犲拰鍋ヨ韩鎴胯鏂戒竴娴侊紝鏅氫笂娉′釜婢″緢鑸掓湇锛?,5.0,'2025-05-17 20:15:00'),(4,2,4,'浣忓湪闀垮煄鑴氫笅鐨勬劅瑙夊お妫掍簡锛佹竻鏅ㄦ帹寮€绐楀氨鑳界湅鍒拌溈铚掔殑闀垮煄锛屾櫙鑹插．瑙傘€傚害鍋囨潙璁炬柦瀹屽杽锛屽伐浣滀汉鍛樻湇鍔℃€佸害寰堝ソ锛屾櫄涓婂弬鍔犱簡绡濈伀party锛屽緢鏈夋剰鎬濄€?,5.0,'2025-05-18 09:40:00'),(5,3,4,'鐜涓嶉敊锛屼絾浠锋牸鍋忛珮锛屾劅瑙夋€т环姣斾笉鏄壒鍒珮銆傛帴閫侀暱鍩庢湇鍔″緢鏂逛究锛岄鍘呯殑椋熺墿鍛抽亾涓嶉敊锛屼絾閫夋嫨涓嶅銆?,4.0,'2025-05-19 16:50:00'),(6,4,7,'閰掑簵浣嶇疆缁濅匠锛屾埧闂撮槼鍙扮洿闈㈣タ婀栵紝鏅壊缇庝笉鑳滄敹銆傛棭涓婇啋鏉ュ氨鑳界湅鍒伴浘姘旂辑缁曠殑婀栭潰锛岄潪甯歌瘲鎰忋€傛湇鍔′篃寰堝埌浣嶏紝宸ヤ綔浜哄憳鐑儏鏈夌ぜ銆?,5.0,'2025-05-20 11:25:00'),(7,2,7,'瑗挎箹闆呭洯鏄垜浣忚繃鏈€缇庣殑閰掑簵涔嬩竴锛屾睙鍗楀洯鏋楀紡鐨勮璁″緢鏈夐煹鍛筹紝瀹㈡埧瀹芥暈鑸掗€傦紝涓嬪崍鑼朵篃寰堢簿鑷淬€傚敮涓€閬楁喚鐨勬槸鍛ㄦ湯浜哄お澶氾紝鏈夌偣鍚点€?,4.5,'2025-05-21 13:10:00'),(8,3,10,'閰掑簵鐜瓒呭嚭棰勬湡锛屾俯娉塖PA闈炲父浜彈锛岀紦瑙ｄ簡涓€澶╃櫥灞辩殑鐤插姵銆傞鍘呯殑寰藉窞鑿滃仛寰楀湴閬撶編鍛筹紝鏈嶅姟鍛橀兘寰堜笓涓氬弸鍠勩€?,5.0,'2025-05-22 19:20:00'),(9,4,10,'璁炬柦涓€娴侊紝鏈嶅姟鍛ㄥ埌锛屼絾浠锋牸纭疄涓嶄究瀹溿€備笉杩囩櫥灞卞墠鍚庝綇杩欓噷寰堝€煎緱锛岀壒鍒槸绉佷汉娓╂硥锛屾场瀹屾暣涓汉閮借交鏉句簡锛?,4.5,'2025-05-23 21:35:00'),(10,2,13,'閰掑簵浣嶇疆濂斤紝灏卞湪瑗胯涓婏紝鍑鸿鏂逛究銆傛埧闂撮槼鍙板彲浠ョ湅鍒版紦姹熷拰鍠€鏂壒灞卞嘲锛岄鏅鐢汇€傛埧闂村共鍑€鑸掗€傦紝鏈嶅姟鐑儏锛屽€煎緱鎺ㄨ崘锛?,4.5,'2025-05-24 10:40:00'),(11,3,13,'鏁翠綋浣撻獙涓嶉敊锛屼絾鎴块棿闅旈煶绋嶅樊锛岃タ琛楁櫄涓婃瘮杈冪儹闂癸紝瀵圭潯鐪犺川閲忔湁浜涘奖鍝嶃€備笉杩囬鏅‘瀹炲緢缇庯紝鏃╅涔熶笉閿欍€?,4.0,'2025-05-25 12:30:00'),(13,3,1,'aa',5.0,'2025-08-03 10:31:49'),(14,3,1,'aaaaa',5.0,'2025-08-03 10:31:57');
/*!40000 ALTER TABLE `accommodation_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accommodation_room_type`
--

DROP TABLE IF EXISTS `accommodation_room_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accommodation_room_type` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `accommodation_id` bigint NOT NULL COMMENT '鎵€灞炰綇瀹縄D',
  `room_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎴垮瀷鍚嶇О锛堝锛氳豹鍗庡ぇ搴婃埧锛?,
  `room_area` int DEFAULT NULL COMMENT '鎴块棿闈㈢Н锛堝钩鏂圭背锛?,
  `bed_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '搴婂瀷锛堝ぇ搴?鍙屽簥/澶氬簥锛?,
  `max_occupancy` int NOT NULL DEFAULT '2' COMMENT '鏈€澶у叆浣忎汉鏁?,
  `has_window` tinyint DEFAULT '1' COMMENT '鏄惁鏈夌獥锛?-鏃狅紝1-鏈?,
  `breakfast` tinyint DEFAULT '0' COMMENT '鏄惁鍚棭椁愶細0-涓嶅惈锛?-鍚?,
  `price` decimal(10,2) NOT NULL COMMENT '鍙傝€冧环鏍硷紙姣忔櫄锛?,
  `discount_price` decimal(10,2) DEFAULT NULL COMMENT '浼樻儬浠锋牸',
  `total_rooms` int NOT NULL COMMENT '璇ョ被鍨嬫埧闂存€绘暟',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎴垮瀷鎻忚堪',
  `facilities` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璁炬柦锛堝锛歐iFi,绌鸿皟,鐢佃绛夛紝閫楀彿鍒嗛殧锛?,
  `image_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎴垮瀷鍥剧墖URL',
  `status` tinyint DEFAULT '1' COMMENT '鐘舵€侊細1-鍙璁紝0-涓嶅彲棰勮',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_accommodation_id` (`accommodation_id`) USING BTREE,
  CONSTRAINT `fk_room_type_accommodation` FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='浣忓鎴垮瀷琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accommodation_room_type`
--

LOCK TABLES `accommodation_room_type` WRITE;
/*!40000 ALTER TABLE `accommodation_room_type` DISABLE KEYS */;
INSERT INTO `accommodation_room_type` VALUES (1,1,'璞崕澶у簥鎴?,45,'澶у簥 (2m*2m)',2,1,1,1880.00,1680.00,20,'铻嶅悎涓紡鍙ゅ吀涓庣幇浠ｅア鍗庣殑璞崕瀹㈡埧锛岄厤澶囩嫭绔嬫荡缂稿拰鏅鸿兘瀹跺眳绯荤粺','鍏嶈垂WiFi,鏅鸿兘鐢佃,涓ぎ绌鸿皟,杩蜂綘鍚?淇濋櫓绠?娴寸几,娴磋,24灏忔椂鐑按','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553065750_565d12949fdf43b18afc61f911f88d60.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(2,1,'琛屾斂濂楁埧',80,'澶у簥 (2m*2m)',2,1,1,3280.00,2980.00,8,'鎷ユ湁鐙珛瀹㈠巺鍜屽崸瀹わ紝鍙刊鐬版晠瀹叏鏅紝灏婁韩琛屾斂閰掑粖寰呴亣','鍏嶈垂WiFi,鏅鸿兘鐢佃,涓ぎ绌鸿皟,杩蜂綘鍚?鍜栧暋鏈?淇濋櫓绠?娴寸几,娴磋,琛屾斂閰掑粖','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553076456_8707a447ff134255a4c949b59bc4ff84.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(3,1,'鏍囧噯鍙屽簥鎴?,35,'鍙屽簥 (1.2m*2m)',2,1,1,1280.00,1080.00,30,'鑸掗€傜殑鍙屽簥鎴匡紝閫傚悎鏈嬪弸鎴栧搴嚭琛?,'鍏嶈垂WiFi,鏅鸿兘鐢佃,涓ぎ绌鸿皟,杩蜂綘鍚?淇濋櫓绠?娣嬫荡,24灏忔椂鐑按','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553037319_292b2ffc35834394ade5312b6df8bc3c.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(4,2,'鏍囧噯澶у簥鎴?,30,'澶у簥 (1.8m*2m)',2,1,1,880.00,780.00,12,'浼犵粺鍥涘悎闄㈤鏍煎鎴匡紝鍙よ壊鍙ら锛屾俯棣ㄨ垝閫?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,鏆栨皵,鐢电儹姘村６,娣嬫荡,鎷栭瀷','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553027393_6cffcbee5db043c4829cb4355a227edb.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(5,2,'瀹跺涵濂楁埧',50,'1寮犲ぇ搴?1寮犲崟浜哄簥',3,1,1,1280.00,1180.00,5,'涓ゅ涓€鍘呮牸灞€锛岄€傚悎鍏ㄥ鍏ヤ綇锛屼綋楠岃€佸寳浜敓娲?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,鏆栨皵,灏忓帹鎴?娣嬫荡,娴寸几,鍎跨鐢ㄥ搧','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553046562_327a8aea489f487eaf776a4abb37a9dd.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(6,3,'澶氫汉闂村簥浣?,25,'涓婁笅閾?,1,1,0,120.00,100.00,40,'骞插噣鏁存磥鐨?浜洪棿/6浜洪棿搴婁綅锛屽叕鍏卞崼娴?,'鍏嶈垂WiFi,鍌ㄧ墿鏌?涔︽,鍙扮伅,鍏叡娣嬫荡,鍏叡鍘ㄦ埧','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774361171447_06c5e855cbf84567a311f76f9dea2bfc.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(7,3,'鍗曚汉闂?,15,'鍗曚汉搴?(1.2m*2m)',1,1,0,280.00,250.00,10,'绉佸瘑鍗曚汉闂达紝鍏叡鍗荡锛岄€傚悎鐙嚜鏃呰鑰?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,涔︽,鍏叡娣嬫荡','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774361182104_0d82e4322f61490e98cf06a0f7da855f.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(8,4,'灞辨櫙澶у簥鎴?,40,'澶у簥 (1.8m*2m)',2,1,1,1680.00,1480.00,15,'鎺ㄧ獥鍗冲彲瑙侀暱鍩庡北鏅紝閰嶅瑙傛櫙闃冲彴','鍏嶈垂WiFi,鏅鸿兘鐢佃,绌鸿皟,杩蜂綘鍚?娴寸几,娴磋,瑙傛櫙闃冲彴','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774553057977_a193fc68b53b4913b74289bea22e891a.png',1,'2026-03-05 16:09:17','2026-03-07 17:19:08'),(9,4,'搴櫌瀹跺涵鎴?,55,'1寮犲ぇ搴?1寮犱笂涓嬮摵',4,1,1,2280.00,1980.00,8,'甯︽湁绉佸瘑灏忛櫌鐨勫搴鎴匡紝鍎跨娓镐箰璁炬柦','鍏嶈垂WiFi,鐢佃,绌鸿皟,杩蜂綘鍚?灏忓啺绠?娴寸几,鍎跨鐜╁叿,搴櫌','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(10,5,'鍐滃鍦熺倳鎴?,25,'鍦熺倳',2,1,1,480.00,450.00,6,'浣撻獙鍖楁柟浼犵粺鍦熺倳锛屽啲鏆栧鍑?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,鐢电儹姣?鍏叡娣嬫荡','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(11,5,'鏍囧噯鍙屽簥鎴?,28,'鍙屽簥 (1.2m*2m)',2,1,1,580.00,520.00,10,'绠€娲佹槑浜殑鍙屽簥鎴匡紝骞插噣鍗敓','鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鎷栭瀷','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(12,6,'闀垮煄鏅鎴?,35,'澶у簥 (1.8m*2m)',2,1,1,980.00,880.00,8,'鎴块棿钀藉湴绐楁瀵归暱鍩庯紝韬哄湪搴婁笂鐪嬫棩鍑?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娴寸几,瑙傛櫙闃冲彴,鑼跺叿','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(13,6,'澶嶅紡瀹跺涵鎴?,60,'1寮犲ぇ搴?2寮犲崟浜哄簥',4,1,1,1580.00,1380.00,4,' loft澶嶅紡缁撴瀯锛屼笅灞傚鍘呬笂灞傚崸瀹?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,灏忓帹鎴?娴寸几,瑙傛櫙闇插彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(14,7,'婀栨櫙澶у簥鎴?,42,'澶у簥 (1.8m*2m)',2,1,1,1580.00,1380.00,18,'姝ｉ潰瑗挎箹锛岄厤鏈夎鏅槼鍙帮紝婀栧厜灞辫壊灏芥敹鐪煎簳','鍏嶈垂WiFi,鏅鸿兘鐢佃,绌鸿皟,杩蜂綘鍚?娴寸几,娴磋,瑙傛櫙闃冲彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(15,7,'搴櫌鍙屽簥鎴?,38,'鍙屽簥 (1.2m*2m)',2,1,1,1080.00,980.00,12,'闈㈠悜姹熷崡搴櫌锛屽畨闈欓泤鑷?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鑼跺叿','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(16,8,'绔规灄澶у簥鎴?,35,'澶у簥 (1.8m*2m)',2,1,1,880.00,780.00,8,'鎺╂槧鍦ㄧ鏋椾腑鐨勫鎴匡紝娓呭菇绉佸瘑','鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鑼跺叿,绔瑰埗瀹跺叿','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(17,8,'澶嶅紡濂楁埧',70,'澶у簥 (1.8m*2m)',2,1,1,1580.00,1380.00,3,'涓ゅ眰缁撴瀯锛屽甫灏忛櫌鍜岃尪瀹?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,灏忓帹鎴?娴寸几,鑼跺,灏忛櫌','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(18,9,'鏂囪壓鍗曚汉闂?,18,'鍗曚汉搴?(1.2m*2m)',1,1,1,280.00,250.00,12,'鏂囪壓椋庢牸瑁呴グ锛岄€傚悎鐙嚜鏃呰鑰?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,涔︽,鍏叡娣嬫荡,鍏变韩闃呰鍖?,'/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(19,9,'婀栨櫙鍙屼汉闂?,25,'鍙屽簥 (1.2m*2m)',2,1,1,380.00,350.00,8,'鍙繙鐪鸿タ婀栵紝鍏叡鍗荡','鍏嶈垂WiFi,鐢佃,绌鸿皟,鍏叡娣嬫荡,瑙傛櫙闇插彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(20,10,'娓╂硥澶у簥鎴?,48,'澶у簥 (2m*2m)',2,1,1,2880.00,2580.00,15,'鎴块棿鍐呭紩鍏ユ俯娉夋按锛岀瀵嗘场姹?,'鍏嶈垂WiFi,鏅鸿兘鐢佃,涓ぎ绌鸿皟,杩蜂綘鍚?绉佷汉娓╂硥姹?娴寸几,娴磋','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(21,10,'灞辨櫙濂楁埧',85,'澶у簥 (2m*2m)',2,1,1,4580.00,3980.00,6,'瓒呭ぇ瑙傛櫙闃冲彴鐩撮潰榛勫北锛屽甫璧峰眳瀹?,'鍏嶈垂WiFi,鏅鸿兘鐢佃,涓ぎ绌鸿皟,杩蜂綘鍚?鍜栧暋鏈?娴寸几,瑙傛櫙闃冲彴,琛屾斂绀奸亣','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(22,11,'寰介煹澶у簥鎴?,30,'澶у簥 (1.8m*2m)',2,1,1,580.00,520.00,10,'寰芥淳鏈ㄩ洉瑁呴グ锛屽彜鑹插彜棣?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鑼跺叿','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(23,11,'鏍囧噯鍙屽簥鎴?,28,'鍙屽簥 (1.2m*2m)',2,1,1,480.00,420.00,12,'绠€娲佽垝閫傦紝鎬т环姣旈珮','鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(24,12,'鐢板洯澶у簥鎴?,35,'澶у簥 (1.8m*2m)',2,1,1,780.00,680.00,8,'鎺ㄧ獥鍗宠鐢板洯椋庡厜锛岄笩璇姳棣?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,闃冲彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(25,12,'浜插瓙瀹跺涵鎴?,45,'1寮犲ぇ搴?1寮犲効绔ュ簥',3,1,1,980.00,880.00,4,'涓撲负浜插瓙璁捐锛屽効绔ュ簥鍜岀帺鍏?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鍎跨鐜╁叿,鍎跨娲楁急鐢ㄥ搧','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(26,13,'婕撴睙鏅澶у簥鎴?,40,'澶у簥 (1.8m*2m)',2,1,1,1280.00,1080.00,16,'姝ｉ潰婕撴睙锛屽甫瑙傛櫙闃冲彴锛屽北姘寸敾鍗峰湪鐪煎墠','鍏嶈垂WiFi,鏅鸿兘鐢佃,绌鸿皟,杩蜂綘鍚?娴寸几,瑙傛櫙闃冲彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(27,13,'璞崕鍙屽簥鎴?,38,'鍙屽簥 (1.2m*2m)',2,1,1,980.00,880.00,20,'鑸掗€傚弻搴婏紝閮ㄥ垎鎴块棿渚ф睙鏅?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,鑼跺叿','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(28,14,'鐢板洯鍙屽簥鎴?,30,'鍙屽簥 (1.2m*2m)',2,1,1,580.00,520.00,8,'鎺ㄧ獥瑙佺敯鍥拰鍠€鏂壒灞卞肠','鍏嶈垂WiFi,鐢佃,绌鸿皟,娣嬫荡,闃冲彴','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(29,14,'鐙爧灏忛櫌',80,'1寮犲ぇ搴?1寮犳姒荤背',4,1,1,1580.00,1380.00,3,'鐙珛灏忛櫌锛屽惈瀹㈠巺銆佸帹鎴垮拰鐑х儰鍖?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,鍘ㄦ埧,鐑х儰鏋?娣嬫荡,娴寸几,绉佸搴櫌','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(30,15,'鍩庡競鏅鍗曚汉闂?,20,'鍗曚汉搴?(1.2m*2m)',1,1,0,180.00,150.00,10,'鐜颁唬绠€绾﹀崟浜洪棿锛屽叕鍏卞崼娴?,'鍏嶈垂WiFi,鐢佃,绌鸿皟,鍌ㄧ墿鏌?鍏叡娣嬫荡','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22'),(31,15,'鍙屼汉鏍囬棿',25,'鍙屽簥 (1.2m*2m)',2,1,0,260.00,230.00,12,'缁忔祹鍙屽簥闂达紝鍏叡鍗荡','鍏嶈垂WiFi,鐢佃,绌鸿皟,涔︽,鍏叡娣嬫荡','/img/1748616500926.jpg',1,'2026-03-05 16:09:17','2026-03-05 20:21:22');
/*!40000 ALTER TABLE `accommodation_room_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carousel`
--

DROP TABLE IF EXISTS `carousel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carousel` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '杞挱鍥炬爣棰?,
  `image_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '杞挱鍥剧墖鍦板潃',
  `status` tinyint DEFAULT '1' COMMENT '鐘舵€? 1-鍚敤, 0-绂佺敤',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carousel`
--

LOCK TABLES `carousel` WRITE;
/*!40000 ALTER TABLE `carousel` DISABLE KEYS */;
INSERT INTO `carousel` VALUES (1,'缇庝附灞辨按','/img/1748615396726.jpeg',1,'2025-05-30 22:25:21','2025-05-30 22:25:21'),(2,'鍙ゅ煄椋庤矊','/img/1748615456649.jpeg',1,'2025-05-30 22:25:21','2025-05-30 22:25:21'),(3,'娴锋花搴﹀亣','/img/1748615479053.jpeg',1,'2025-05-30 22:25:21','2025-05-30 22:25:21'),(4,'姘戜織鏂囧寲','/img/1748615578372.jpg',1,'2025-05-30 22:25:21','2025-05-30 22:25:21'),(5,'鍩庡競澶滄櫙','/img/1748615616796.jpg',0,'2025-05-30 22:25:21','2025-05-30 22:33:40');
/*!40000 ALTER TABLE `carousel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection`
--

DROP TABLE IF EXISTS `collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏀惰棌ID',
  `user_id` bigint DEFAULT NULL COMMENT '鐢ㄦ埛ID',
  `guide_id` bigint DEFAULT NULL COMMENT '鏀荤暐ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `guide_id` (`guide_id`) USING BTREE,
  CONSTRAINT `collection_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `collection_ibfk_2` FOREIGN KEY (`guide_id`) REFERENCES `travel_guide` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏀惰棌琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection`
--

LOCK TABLES `collection` WRITE;
/*!40000 ALTER TABLE `collection` DISABLE KEYS */;
INSERT INTO `collection` VALUES (3,3,1,'2025-05-14 14:02:00'),(5,4,1,'2025-05-14 14:04:00'),(6,4,2,'2025-05-14 14:05:00'),(13,2,4,'2025-05-31 02:12:48'),(16,3,3,'2025-08-03 12:35:04'),(17,3,4,'2025-08-03 17:21:40'),(20,12,4,'2026-03-27 03:37:27');
/*!40000 ALTER TABLE `collection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇勮ID',
  `user_id` bigint DEFAULT NULL COMMENT '鐢ㄦ埛ID',
  `scenic_id` bigint DEFAULT NULL COMMENT '鏅偣ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇勮鍐呭',
  `rating` int DEFAULT NULL COMMENT '璇勫垎(1-5)',
  `likes` int DEFAULT '0' COMMENT '鐐硅禐鏁?,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `scenic_id` (`scenic_id`) USING BTREE,
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`scenic_id`) REFERENCES `scenic_spot` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璇勮琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (1,2,1,'鏁呭鐪熺殑寰堝．瑙傦紝鍘嗗彶鎰熷緢寮猴紝鍊煎緱涓€鍘伙紒',5,14,'2025-05-14 12:00:00'),(3,4,2,'闀垮煄寰堥泟浼燂紝鐖捣鏉ユ湁鐐圭疮锛屼絾椋庢櫙缁濅匠锛?,5,15,'2025-05-14 12:02:00'),(9,3,4,'妫掟煈?,5,1,'2025-08-03 17:55:41');
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_like`
--

DROP TABLE IF EXISTS `comment_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment_like` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐐硅禐ID',
  `user_id` bigint DEFAULT NULL COMMENT '鐢ㄦ埛ID',
  `comment_id` bigint DEFAULT NULL COMMENT '璇勮ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_comment` (`user_id`,`comment_id`) USING BTREE,
  KEY `comment_id` (`comment_id`) USING BTREE,
  CONSTRAINT `comment_like_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `comment_like_ibfk_2` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璇勮鐐硅禐鍏崇郴琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_like`
--

LOCK TABLES `comment_like` WRITE;
/*!40000 ALTER TABLE `comment_like` DISABLE KEYS */;
INSERT INTO `comment_like` VALUES (9,12,9,'2026-03-27 03:38:38');
/*!40000 ALTER TABLE `comment_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_category`
--

DROP TABLE IF EXISTS `scenic_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍒嗙被ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍒嗙被鍚嶇О',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍒嗙被鎻忚堪',
  `icon` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍒嗙被鍥炬爣',
  `parent_id` bigint DEFAULT '0' COMMENT '鐖跺垎绫籌D锛?琛ㄧず涓€绾у垎绫?,
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭搴忓彿',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏅偣鍒嗙被琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_category`
--

LOCK TABLES `scenic_category` WRITE;
/*!40000 ALTER TABLE `scenic_category` DISABLE KEYS */;
INSERT INTO `scenic_category` VALUES (1,'鑷劧椋庡厜','鍖呮嫭灞辨按銆佹箹娉娿€佺€戝竷绛夎嚜鐒舵櫙瑙?,'/img/category/nature.png',0,1,'2025-05-29 15:31:47','2025-05-29 15:31:47'),(2,'鍘嗗彶鏂囧寲','鍖呮嫭鍙よ抗銆佸崥鐗╅銆佸巻鍙查仐鍧€绛?,'/img/category/history.png',0,2,'2025-05-29 15:31:47','2025-05-29 15:31:47'),(3,'涓婚鍏洯','鍚勭被涓婚涔愬洯銆佹父涔愬満绛?,'/img/category/theme.png',0,3,'2025-05-29 15:31:47','2025-05-29 15:31:47'),(4,'鍩庡競鍦版爣','鍩庡競涓殑鏍囧織鎬у缓绛戝拰鏅偣','/img/category/landmark.png',0,4,'2025-05-29 15:31:47','2025-05-29 15:31:47'),(5,'涔℃潙姘戜織','涔℃潙椋庡厜銆佹皯淇楁枃鍖栦綋楠屽湴','/img/category/rural.png',0,5,'2025-05-29 15:31:47','2025-05-29 15:31:47');
/*!40000 ALTER TABLE `scenic_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_collection`
--

DROP TABLE IF EXISTS `scenic_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_collection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏀惰棌ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `scenic_id` bigint NOT NULL COMMENT '鏅偣ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_scenic` (`user_id`,`scenic_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_scenic_id` (`scenic_id`) USING BTREE,
  CONSTRAINT `scenic_collection_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `scenic_collection_ibfk_2` FOREIGN KEY (`scenic_id`) REFERENCES `scenic_spot` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏅偣鏀惰棌琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_collection`
--

LOCK TABLES `scenic_collection` WRITE;
/*!40000 ALTER TABLE `scenic_collection` DISABLE KEYS */;
INSERT INTO `scenic_collection` VALUES (9,6,4,'2025-06-19 21:37:42'),(10,6,1,'2025-06-19 21:38:51'),(13,3,4,'2025-08-03 12:22:56'),(14,3,3,'2025-08-03 12:34:11'),(17,3,5,'2025-08-03 17:20:59');
/*!40000 ALTER TABLE `scenic_collection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_spot`
--

DROP TABLE IF EXISTS `scenic_spot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_spot` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏅偣ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏅偣鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鏅偣鎻忚堪',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍦扮悊浣嶇疆',
  `price` decimal(10,2) DEFAULT NULL COMMENT '绁ㄤ环',
  `opening_hours` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寮€鏀炬椂闂?,
  `image_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍥剧墖URL',
  `longitude` decimal(10,6) DEFAULT NULL COMMENT '缁忓害',
  `latitude` decimal(10,6) DEFAULT NULL COMMENT '绾害',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `category_id` bigint DEFAULT NULL COMMENT '鍒嗙被ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏅偣淇℃伅琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_spot`
--

LOCK TABLES `scenic_spot` WRITE;
/*!40000 ALTER TABLE `scenic_spot` DISABLE KEYS */;
INSERT INTO `scenic_spot` VALUES (1,'鏁呭鍗氱墿闄?,'鏁呭鍗氱墿闄綅浜庡寳浜競涓績锛屾槸鏄庢竻涓や唬鐨勭殗瀹跺娈匡紝涓栫晫涓婄幇瀛樿妯℃渶澶с€佷繚瀛樻渶涓哄畬鏁寸殑鏈ㄨ川缁撴瀯鍙ゅ缓绛戜箣涓€銆?,'鍖椾含甯?- 鍖椾含甯?- 鏄屽钩鍖?,60.00,'8:30-17:00锛堝懆涓€闂锛?,'/img/1748616033437.jpg',116.397428,39.916527,'2025-05-14 11:00:00','2025-05-30 22:40:34',2),(2,'闀垮煄','闀垮煄鏄腑鍥藉彜浠ｇ殑浼熷ぇ闃插尽宸ョ▼锛屼篃鏄笘鐣屼笂鏈€浼熷ぇ鐨勫缓绛戜箣涓€锛岃鍒椾负涓栫晫鏂囧寲閬椾骇銆?,'鍖椾含甯傛€€鏌斿尯',45.00,'8:00-17:00','/img/1748616061193.jpg',116.604642,40.315634,'2025-05-14 11:01:00','2025-05-30 22:41:02',2),(3,'瑗挎箹','瑗挎箹浣嶄簬娴欐睙鐪佹澀宸炲競瑗块潰锛屾槸涓浗澶ч檰棣栨壒鍥藉閲嶇偣椋庢櫙鍚嶈儨鍖轰箣涓€锛屾湁\"浜洪棿澶╁爞\"鐨勭編瑾夈€?,'娴欐睙鐪佹澀宸炲競瑗挎箹鍖?,0.00,'鍏ㄥぉ寮€鏀?,'/img/1748616086868.jpg',120.155070,30.287459,'2025-05-14 11:02:00','2025-05-30 22:41:27',1),(4,'榛勫北','榛勫北浣嶄簬瀹夊窘鐪佸崡閮紝鏄腑鍥藉崄澶у悕灞变箣涓€锛屼互濂囨澗銆佹€煶銆佷簯娴枫€佹俯娉塡"鍥涚粷\"钁楃О浜庝笘銆?,'瀹夊窘鐪侀粍灞卞競',190.00,'6:30-16:30','/img/1748616133671.jpg',118.237474,29.709239,'2025-05-14 11:03:00','2025-05-30 22:42:14',1),(5,'妗傛灄灞辨按','妗傛灄灞辨按鏄寚妗傛灄婕撴睙鏅尯鐨勫北姘撮鍏夛紝浠"灞遍潚銆佹按绉€銆佹礊濂囥€佺煶缇嶾"鍥涘ぇ鐗圭偣钁楃О銆?,'骞胯タ澹棌鑷不鍖?- 妗傛灄甯?- 璞″北鍖?,120.00,'8:00-17:30','/img/1748616162313.jpg',110.299118,25.267493,'2025-05-14 11:04:00','2025-05-30 22:42:43',1),(9,'浣撹偛瑗?,' 浣撹偛瑗匡紝鍏ㄧО鈥滀綋鑲茶タ璺€濓紝浣嶄簬骞垮窞甯傚ぉ娌冲尯鏍稿績鍦板甫锛屾槸骞垮窞鏈€绻佸崕鐨勫晢鍦堜箣涓€銆?瀹冧笉浠呮槸涓€鏉¤閬撶殑鍚嶅瓧锛屾洿鏄竴涓煄甯傜敓娲荤鍙封€斺€旇繖閲屾槸骞垮窞浜虹殑鈥滃績澶村ソ鈥濓紝涔熸槸娓稿蹇呮墦鍗＄殑鈥滅綉绾浣嶁€濄€?,'骞夸笢鐪?- 骞垮窞甯?- 澶╂渤鍖?,0.00,'','https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1774551334574_b07edc2315b9498ab30beac3327dde9a.png',116.153532,23.301304,'2026-03-07 17:08:52','2026-03-27 02:56:12',4);
/*!40000 ALTER TABLE `scenic_spot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket`
--

DROP TABLE IF EXISTS `ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `scenic_id` bigint NOT NULL,
  `ticket_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '闂ㄧエ鍚嶇О',
  `price` decimal(10,2) NOT NULL,
  `discount_price` decimal(10,2) DEFAULT NULL COMMENT '浼樻儬浠锋牸',
  `ticket_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '闂ㄧエ绫诲瀷(鎴愪汉绁?鍎跨绁?瀛︾敓绁ㄧ瓑)',
  `valid_period` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏈夋晥鏈?,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `stock` int DEFAULT NULL COMMENT '鍓╀綑鏁伴噺',
  `status` tinyint DEFAULT '1' COMMENT '鐘舵€? 1-鍙璁? 0-涓嶅彲棰勮',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `scenic_id` (`scenic_id`) USING BTREE,
  CONSTRAINT `ticket_ibfk_1` FOREIGN KEY (`scenic_id`) REFERENCES `scenic_spot` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket`
--

LOCK TABLES `ticket` WRITE;
/*!40000 ALTER TABLE `ticket` DISABLE KEYS */;
INSERT INTO `ticket` VALUES (1,1,'鏁呭鍗氱墿闄?鎴愪汉绁?,80.00,60.00,'鎴愪汉绁?,'璐拱鍚?0澶╁唴鏈夋晥','鏁呭鍗氱墿闄㈡爣鍑嗘垚浜虹エ锛屽惈鍩烘湰鍙傝椤圭洰锛屼笉鍖呭惈鐝嶅疂棣嗐€侀挓琛ㄩ绛夌壒娈婂睍鍘?,994,1,'2025-05-30 11:18:59','2025-08-03 12:39:42'),(2,1,'鏁呭鍗氱墿闄?瀛︾敓绁?,60.00,40.00,'瀛︾敓绁?,'璐拱鍚?0澶╁唴鏈夋晥锛岄渶鍑虹ず鏈夋晥瀛︾敓璇?,'鏁呭鍗氱墿闄㈠鐢熶紭鎯犵エ锛屽惈鍩烘湰鍙傝椤圭洰锛屼笉鍖呭惈鐝嶅疂棣嗐€侀挓琛ㄩ绛夌壒娈婂睍鍘?,487,1,'2025-05-30 11:18:59','2025-05-31 02:21:21'),(3,1,'鏁呭鍗氱墿闄?鐗规儬濂楃エ',120.00,100.00,'鐗规儬濂楃エ','璐拱鍚?0澶╁唴鏈夋晥','鏁呭鍗氱墿闄㈢壒鎯犲绁紝鍚熀鏈弬瑙傞」鐩強鐝嶅疂棣嗐€侀挓琛ㄩ鐗规畩灞曞巺',298,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(4,2,'鍏揪宀暱鍩?鎴愪汉绁?,60.00,45.00,'鎴愪汉绁?,'浠呴檺褰撳ぉ浣跨敤','闀垮煄鍏揪宀鎴愪汉鏍囧噯闂ㄧエ锛屽惈寰€杩旂紗杞?,1499,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(5,2,'鍏揪宀暱鍩?鍎跨绁?,30.00,25.00,'鍎跨绁?,'浠呴檺褰撳ぉ浣跨敤锛?.2绫充互涓嬪効绔ュ厤绁?,'闀垮煄鍏揪宀鍎跨浼樻儬闂ㄧエ锛屽惈寰€杩旂紗杞?,497,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(6,2,'鍏揪宀暱鍩?鑰佷汉绁?,30.00,25.00,'鑰佷汉绁?,'浠呴檺褰撳ぉ浣跨敤锛岄渶鍑虹ず鑰佸勾璇?,'闀垮煄鍏揪宀鑰佷汉浼樻儬闂ㄧエ锛屽惈寰€杩旂紗杞?,298,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(7,3,'瑗挎箹鏅尯-鑱旂エ',80.00,70.00,'鑱旂エ','璐拱鍚?澶╁唴鏈夋晥','瑗挎箹鏅尯鑱旂エ锛屽寘鍚柇妗ャ€侀浄宄板銆佷笁娼嵃鏈堢瓑鏅偣',2000,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(8,3,'瑗挎箹娓歌埞绁?鎴愪汉',60.00,55.00,'鎴愪汉绁?,'璐拱鍚庡綋澶╂湁鏁?,'瑗挎箹娓歌埞鏍囧噯绁紝鍚幆婀栨父鑸规湇鍔?,996,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(9,3,'瑗挎箹娓歌埞绁?鍎跨',30.00,25.00,'鍎跨绁?,'璐拱鍚庡綋澶╂湁鏁堬紝1.2绫充互涓嬪効绔ュ厤绁?,'瑗挎箹娓歌埞鍎跨绁紝鍚幆婀栨父鑸规湇鍔?,499,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(10,4,'榛勫北椋庢櫙鍖?鎴愪汉绁?,230.00,190.00,'鎴愪汉绁?,'璐拱鍚?澶╁唴鏈夋晥','榛勫北椋庢櫙鍖烘垚浜洪棬绁紝涓嶅惈缂嗚溅璐圭敤',794,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(11,4,'榛勫北椋庢櫙鍖?瀛︾敓绁?,160.00,115.00,'瀛︾敓绁?,'璐拱鍚?澶╁唴鏈夋晥锛岄渶鍑虹ず鏈夋晥瀛︾敓璇?,'榛勫北椋庢櫙鍖哄鐢熶紭鎯犵エ锛屼笉鍚紗杞﹁垂鐢?,397,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(12,4,'榛勫北椋庢櫙鍖?涓ゆ棩娓稿绁?,350.00,320.00,'濂楃エ','璐拱鍚?澶╁唴鏈夋晥锛岃繛缁袱澶╀娇鐢?,'榛勫北椋庢櫙鍖轰袱鏃ユ父濂楃エ锛屽惈灞变笂浣忓涓€鏅氾紝涓嶅惈缂嗚溅璐圭敤',200,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(13,5,'婕撴睙绮惧崕娓?鎴愪汉绁?,220.00,180.00,'鎴愪汉绁?,'璐拱鍚?5澶╁唴鏈夋晥','婕撴睙绮惧崕娈电绛忔紓娴侊紝鍚帴閫佹湇鍔?,597,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(14,5,'婕撴睙绮惧崕娓?鍎跨绁?,120.00,100.00,'鍎跨绁?,'璐拱鍚?5澶╁唴鏈夋晥锛?.2绫充互涓嬪効绔ュ厤绁?,'婕撴睙绮惧崕娈电绛忔紓娴佸効绔ョエ锛屽惈鎺ラ€佹湇鍔?,295,1,'2025-05-30 11:18:59','2025-05-30 11:18:59'),(15,5,'妗傛灄灞辨按涓€鏃ユ父濂楃エ',280.00,250.00,'濂楃エ','璐拱鍚?5澶╁唴鏈夋晥','鍚紦姹熺簿鍗庢婕傛祦銆佽薄灞卞叕鍥€佷竷鏄熷叕鍥瓑鏅偣闂ㄧエ锛屽惈鍗堥鍜屾帴閫佹湇鍔?,199,1,'2025-05-30 11:18:59','2025-05-30 11:18:59');
/*!40000 ALTER TABLE `ticket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_order`
--

DROP TABLE IF EXISTS `ticket_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璁㈠崟缂栧彿',
  `user_id` bigint NOT NULL,
  `ticket_id` bigint NOT NULL,
  `quantity` int NOT NULL COMMENT '璐拱鏁伴噺',
  `visitor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '娓稿濮撳悕',
  `visitor_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '娓稿鎵嬫満鍙?,
  `id_card` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '韬唤璇佸彿',
  `visit_date` date NOT NULL COMMENT '娓哥帺鏃ユ湡',
  `total_amount` decimal(10,2) NOT NULL COMMENT '璁㈠崟鎬婚噾棰?,
  `status` tinyint DEFAULT '0' COMMENT '0-寰呮敮浠? 1-宸叉敮浠? 2-宸插彇娑? 3-宸查€€娆? 4-宸插畬鎴?,
  `payment_time` datetime DEFAULT NULL COMMENT '鏀粯鏃堕棿',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏀粯鏂瑰紡',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `ticket_id` (`ticket_id`) USING BTREE,
  CONSTRAINT `ticket_order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ticket_order_ibfk_2` FOREIGN KEY (`ticket_id`) REFERENCES `ticket` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_order`
--

LOCK TABLES `ticket_order` WRITE;
/*!40000 ALTER TABLE `ticket_order` DISABLE KEYS */;
INSERT INTO `ticket_order` VALUES (1,'ORD202505151001',2,1,2,'寮犱笁','13712345678','110101199001011234','2025-06-01',120.00,4,'2025-05-15 10:30:00','ALIPAY','2025-05-15 10:01:00','2025-05-15 10:30:00'),(2,'ORD202505151002',3,4,3,'鏉庡洓','13812345679','310101199102023456','2025-06-05',135.00,1,'2025-05-15 11:15:00','WECHAT','2025-05-15 11:02:00','2025-05-15 11:15:00'),(3,'ORD202505151003',4,10,1,'鐜嬩簲','13912345670','440101199203034567','2025-06-10',190.00,0,NULL,NULL,'2025-05-15 14:05:00','2025-05-15 14:05:00'),(4,'ORD202505151004',2,7,2,'寮犱笁','13712345678','110101199001011234','2025-06-15',140.00,3,'2025-05-15 15:30:00','ALIPAY','2025-05-15 15:10:00','2025-05-15 16:20:00'),(5,'ORD202505151005',3,13,1,'鏉庡洓','13812345679','310101199102023456','2025-06-20',180.00,2,NULL,NULL,'2025-05-15 16:30:00','2025-05-15 16:45:00'),(6,'20250530114026df64',2,2,2,'jx','13456789991','320821200104093911','2025-05-29',80.00,1,'2025-05-30 11:40:33','WECHAT',NULL,NULL),(8,'2025053111515351c2',2,8,1,'娴嬭瘯','13123456789','','2025-05-30',55.00,3,'2025-05-30 12:07:33','ALIPAY','2025-05-30 11:52:53','2025-05-30 12:06:44'),(9,'20250530121135b910',2,1,1,'ces','15252393500','','2025-05-29',60.00,1,'2025-05-30 12:12:00','ALIPAY','2025-05-30 12:11:35','2025-05-30 12:12:00'),(10,'202505301212522f0a',2,6,1,'ces','13123456789','','2025-06-04',25.00,1,'2025-05-30 12:13:17','ALIPAY','2025-05-30 12:12:52','2025-05-30 12:13:17'),(11,'202505301116277781',2,8,1,'ces','13456789987','','2025-05-29',55.00,4,'2025-05-30 12:19:36','ALIPAY','2025-05-30 12:16:27','2025-05-30 12:18:35'),(12,'20250530231406b2a1',2,5,1,'寮犱笁','13712345678','','2025-05-30',25.00,0,NULL,NULL,'2025-05-30 23:14:06',NULL),(13,'20250531022028b885',2,3,1,'寮犱笁','13712345678','','2025-05-30',100.00,1,'2025-05-31 02:20:33','BANK_CARD','2025-05-31 02:20:28','2025-05-31 02:20:32'),(14,'202508030648243821',2,2,1,'寮犱笁','13712345678','','2025-08-02',40.00,0,NULL,NULL,'2025-08-03 06:48:24',NULL),(15,'20250803064835547f',2,2,1,'寮犱笁','13712345678','','2025-08-02',40.00,1,'2025-08-03 06:48:40','WECHAT','2025-08-03 06:48:35','2025-08-03 06:48:40'),(16,'20250803064953425b',2,8,1,'寮犱笁','13712345678','','2025-08-02',55.00,1,'2025-08-03 06:50:57','WECHAT','2025-08-03 06:49:53','2025-08-03 06:50:56'),(17,'202508030716102ebe',2,5,1,'寮犱笁','13800138001','','2025-08-02',25.00,0,NULL,NULL,'2025-08-03 07:16:10',NULL),(18,'202508030716378386',2,5,1,'寮犱笁','13800138001','','2025-08-02',25.00,0,NULL,NULL,'2025-08-03 07:16:37',NULL),(19,'20250803072056f8e0',2,10,1,'寮犱笁','13800138001','','2025-08-02',190.00,1,'2025-08-03 07:21:00','WECHAT','2025-08-03 07:20:56','2025-08-03 07:20:59'),(20,'2025080307402693aa',2,2,1,'寮犱笁','13800138001','','2025-08-02',40.00,1,'2025-08-03 07:40:31','WECHAT','2025-08-03 07:40:26','2025-08-03 07:40:30'),(21,'20250803074317bfeb',2,13,1,'寮犱笁','13800138001','','2025-08-02',180.00,1,'2025-08-03 07:43:23','WECHAT','2025-08-03 07:43:17','2025-08-03 07:43:22'),(22,'20250803074418bf9c',2,2,1,'寮犱笁','13800138001','','2025-08-02',40.00,1,'2025-08-03 07:56:55','WECHAT','2025-08-03 07:44:18','2025-08-03 07:56:55'),(23,'202508030749096a1d',2,2,1,'寮犱笁','13800138001','','2025-08-02',40.00,0,NULL,NULL,'2025-08-03 07:49:10',NULL),(24,'20250803075714910b',2,13,1,'寮犱笁','13800138001','','2025-08-02',180.00,0,NULL,NULL,'2025-08-03 07:57:14',NULL),(25,'202508030800271ee7',2,6,1,'寮犱笁','13800138001','','2025-08-03',25.00,0,NULL,NULL,'2025-08-03 08:00:27',NULL),(26,'202508030807200947',2,1,1,'寮犱笁','13712345678','','2025-08-03',60.00,0,NULL,NULL,'2025-08-03 08:07:20',NULL),(27,'20250803083122bd5e',2,11,1,'寮犱笁','13712345678','','2025-08-03',115.00,0,NULL,NULL,'2025-08-03 08:31:22',NULL),(28,'20250803083843de70',2,10,1,'寮犱笁','13712345678','','2025-08-03',190.00,0,NULL,NULL,'2025-08-03 08:38:43',NULL),(29,'202508030843495856',2,10,1,'寮犱笁','13712345678','','2025-08-03',190.00,0,NULL,NULL,'2025-08-03 08:43:49',NULL),(30,'20250803084642482a',2,13,1,'寮犱笁','13712345678','','2025-08-03',180.00,0,NULL,NULL,'2025-08-03 08:46:42',NULL),(31,'202508030850265d86',2,10,1,'寮犱笁','13712345678','','2025-08-03',190.00,0,NULL,NULL,'2025-08-03 08:50:26',NULL),(32,'20250803085252b690',2,15,1,'寮犱笁','13712345678','','2025-08-03',250.00,0,NULL,NULL,'2025-08-03 08:52:52',NULL),(33,'20250803085438fe98',2,8,1,'寮犱笁','13712345678','','2025-08-03',55.00,1,'2025-08-03 09:00:10','BANK_CARD','2025-08-03 08:54:38','2025-08-03 09:00:10'),(34,'202508030908293eef',2,10,1,'寮犱笁','13712345678','','2025-08-03',190.00,0,NULL,NULL,'2025-08-03 09:08:29',NULL),(35,'202508030912271ed4',2,14,1,'寮犱笁','13712345678','','2025-08-03',100.00,0,NULL,NULL,'2025-08-03 09:12:27',NULL),(36,'2025080309243137bd',3,10,1,'鏉庡洓','13812345679','','2025-08-03',190.00,0,NULL,NULL,'2025-08-03 09:24:31',NULL),(37,'20250803092919d336',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,2,NULL,NULL,'2025-08-03 09:29:19','2025-08-03 17:21:25'),(38,'20250803092951119b',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,2,NULL,NULL,'2025-08-03 09:29:51','2025-08-03 09:30:01'),(39,'202508030930117db9',3,4,1,'鏉庡洓','13812345679','','2025-08-03',45.00,2,NULL,NULL,'2025-08-03 09:30:11','2025-08-03 09:31:39'),(40,'20250803093419a78d',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,1,'2025-08-03 12:37:27','WECHAT','2025-08-03 09:34:19','2025-08-03 12:37:27'),(41,'20250803094021df75',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,1,'2025-08-03 12:34:41','WECHAT','2025-08-03 09:40:21','2025-08-03 12:34:41'),(42,'20250803094119dcec',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,1,'2025-08-03 09:41:22','WECHAT','2025-08-03 09:41:19','2025-08-03 09:41:22'),(43,'202508030942470003',3,6,1,'鏉庡洓','13812345679','','2025-08-03',25.00,2,NULL,NULL,'2025-08-03 09:42:47','2025-08-03 09:43:39'),(44,'20250803094341c388',3,2,1,'鏉庡洓','13812345679','','2025-08-03',40.00,1,'2025-08-03 09:45:38','BANK_CARD','2025-08-03 09:43:41','2025-08-03 09:45:37'),(45,'20250803094509c225',3,2,1,'鏉庡洓','13812345679','','2025-08-03',40.00,2,NULL,NULL,'2025-08-03 09:45:09','2025-08-03 09:45:16'),(46,'20250803094518a3e6',3,3,1,'鏉庡洓','13812345679','','2025-08-03',100.00,1,'2025-08-03 09:45:23','WECHAT','2025-08-03 09:45:18','2025-08-03 09:45:23'),(47,'20250803095020b878',3,2,1,'鏉庡洓','13812345679','','2025-08-03',40.00,1,'2025-08-03 10:16:26','ALIPAY','2025-08-03 09:50:20','2025-08-03 10:16:25'),(48,'202508030952352616',3,8,1,'鏉庡洓','13812345679','','2025-08-03',55.00,1,'2025-08-03 10:14:46','ALIPAY','2025-08-03 09:52:35','2025-08-03 10:14:46'),(49,'202508031010318528',3,1,1,'鏉庡洓','13812345679','','2025-08-03',60.00,4,'2025-08-03 10:14:13','ALIPAY','2025-08-03 10:10:31','2025-08-03 10:14:12'),(50,'202508031223153b38',3,11,2,'鏉庡洓','13812345679','','2025-08-03',230.00,1,'2025-08-03 12:23:21','ALIPAY','2025-08-03 12:23:15','2025-08-03 12:23:20'),(51,'20250803123423f965',3,9,1,'鏉庡洓','13812345679','','2025-08-03',25.00,1,'2025-08-03 12:34:28','ALIPAY','2025-08-03 12:34:23','2025-08-03 12:34:27'),(52,'202508031237115f04',3,2,1,'鏉庡洓','13812345679','','2025-08-03',40.00,4,'2025-08-03 12:37:17','ALIPAY','2025-08-03 12:37:11','2025-08-03 12:37:16'),(53,'202508031721105ff9',3,14,1,'鏉庡洓','13812345679','','2025-08-03',100.00,1,'2025-08-03 17:21:14','ALIPAY','2025-08-03 17:21:10','2025-08-03 17:21:14'),(54,'20250803172206af29',3,4,1,'鏉庡洓','13812345679','','2025-08-03',45.00,1,'2025-08-03 17:22:08','BANK_CARD','2025-08-03 17:22:06','2025-08-03 17:22:08');
/*!40000 ALTER TABLE `ticket_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `travel_guide`
--

DROP TABLE IF EXISTS `travel_guide`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `travel_guide` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏀荤暐ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏍囬',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍐呭',
  `user_id` bigint DEFAULT NULL COMMENT '浣滆€匢D',
  `cover_image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '灏侀潰鍥剧墖',
  `views` int DEFAULT '0' COMMENT '娴忚閲?,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  CONSTRAINT `travel_guide_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏃呮父鏀荤暐琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `travel_guide`
--

LOCK TABLES `travel_guide` WRITE;
/*!40000 ALTER TABLE `travel_guide` DISABLE KEYS */;
INSERT INTO `travel_guide` VALUES (1,'鍖椾含涓夋棩娓稿畬鍏ㄦ敾鐣?,'<p># 鍖椾含涓夋棩娓稿畬鍏ㄦ敾鐣?/p><p><img src=\"/api/img/1748498785197.jpg\" alt=\"\" data-href=\"\" style=\"\"/></p><p>## 绗竴澶╋細鏁呭 + 澶╁畨闂ㄥ箍鍦?+ 鐜嬪簻浜?/p><p>涓婂崍鍙傝鏁呭鍗氱墿闄紝涓嬪崍娓歌澶╁畨闂ㄥ箍鍦猴紝鏅氫笂鍙互鍘荤帇搴滀簳閫涜鍝佸皾灏忓悆銆?/p><p><br></p><p>## 绗簩澶╋細闀垮煄 + 棰愬拰鍥?</p><p>涓婂崍鍓嶅線鍏揪宀暱鍩庯紝涓嬪崍娓歌棰愬拰鍥紝鎰熷彈鐨囧鍥灄鐨勯瓍鍔涖€?/p><p><br></p><p>## 绗笁澶╋細798鑹烘湳鍖?+ 鍗楅敚榧撳贩</p><p>涓婂崍鍙傝798鑹烘湳鍖猴紝鎰熷彈鐜颁唬鑹烘湳姘涘洿锛屼笅鍗堟父瑙堝崡閿ｉ紦宸凤紝浣撻獙鑰佸寳浜儭鍚屾枃鍖栥€?/p>',2,'/img/1748616360745.jpg',1271,'2025-05-14 13:00:00','2026-03-27 03:35:23'),(2,'鏉窞瑗挎箹涓€鏃ユ父','<p># 鏉窞瑗挎箹涓€鏃ユ父</p><p><br></p><p>## 涓婂崍锛氭柇妗ユ畫闆?+ 鐧藉牑</p><p>浠庢柇妗ュ紑濮嬶紝娌跨潃鐧藉牑婕锛屾璧忚タ婀栫編鏅€?/p><p><br></p><p>## 涓崍锛氭ゼ澶栨ゼ鐢ㄩ</p><p>鍦ㄦゼ澶栨ゼ鍝佸皾姝ｅ畻鏉府鑿滐紝濡傝タ婀栭唻楸肩瓑鐗硅壊缇庨銆?/p><p><br></p><p>## 涓嬪崍锛氶浄宄板 + 涓夋江鍗版湀</p><p>鍙傝闆峰嘲濉旓紝涔樿埞娓歌涓夋江鍗版湀锛屾劅鍙梊"瑗挎箹鍗佹櫙\"鐨勯瓍鍔涖€?/p>',3,'/img/1748616297105.jpg',991,'2025-05-14 13:01:00','2026-03-27 03:35:21'),(3,'榛勫北浜屾棩娓告敾鐣?,'<p># 榛勫北浜屾棩娓告敾鐣?/p><p><br></p><p>## 绗竴澶╋細浜戣胺瀵?鈫?鐧介箙宀?鈫?鍖楁捣鏅尯 鈫?鍏夋槑椤?/p><p>涓婂崍浠庝簯璋峰杩涘北锛岀粡鐧介箙宀埌杈惧寳娴锋櫙鍖猴紝涓嬪崍鐧婚《鍏夋槑椤讹紝鏅氫笂鍏ヤ綇灞遍《閰掑簵銆?/p><p><br></p><p>## 绗簩澶╋細瑙傛棩鍑?鈫?瑗挎捣澶у场璋?鈫?鎺掍簯浜?鈫?娓╂硥</p><p>娓呮櫒瑙傝祻鏃ュ嚭锛屼笂鍗堟父瑙堣タ娴峰ぇ宄¤胺锛屼笅鍗堢粡鎺掍簯浜笅灞憋紝鍙互鍦ㄥ北鑴氱殑娓╂硥鏀炬澗韬績銆?/p>',4,'/img/1748616271030.jpg',1108,'2025-05-14 13:02:00','2026-03-27 03:35:19'),(4,'妗傛灄灞辨按绮惧崕涓夋棩娓?,'<p>妗傛灄灞辨按绮惧崕涓夋棩娓?/p><p><br></p><p>绗竴澶╋細璞″北鍏洯 + 涓冩槦鍏洯</p><p>娓歌甯傚尯鍐呯殑璞″北鍏洯鍜屼竷鏄熷叕鍥紝鎰熷彈妗傛灄甯傚尯鐨勫北姘翠箣缇庛€?/p><p><br></p><p> 绗簩澶╋細婕撴睙绮惧崕娈垫紓娴?/p><p>浠庢鏋椾箻鑸硅嚦闃虫湐锛屾璧忔紦姹熶袱宀哥殑澹附椋庡厜锛岃繖鏄鏋楁渶绮惧崕鐨勬櫙瑙傘€?/p><p><br></p><p>绗笁澶╋細闃虫湐瑗胯 + 鍗侀噷鐢诲粖</p><p>涓婂崍娓歌闃虫湐瑗胯锛屼笅鍗堥獞琛屾垨涔樿溅娓歌鍗侀噷鐢诲粖锛屾璧忕敯鍥鍏夈€?/p>',2,'/img/1748616225252.jpg',894,'2025-05-14 13:03:00','2026-04-07 04:20:01'),(10,'鍖椾含涓€鏃ユ父','<p>鍖椾含涓€鏃ユ父</p>\n<!-- GUIDE_ROUTE:W3siaWQiOiIxNzc1MDI0MTM1NjQ5XzAiLCJuYW1lIjoi5YyX5Lqs5aSW5Zu96K+t5aSn5a2m6KW/5qCh5Yy6IiwibG5nIjoxMTYuMzA0NjM2LCJsYXQiOjM5Ljk1MzY2Mn0seyJpZCI6IjE3NzUwMjQxMzU2NDlfMSIsIm5hbWUiOiLljJfkuInnjq/kuJzot68xMeWPt+mZoiIsImxuZyI6MTE2LjQyNTg1OSwibGF0IjozOS45NzE1ODd9LHsiaWQiOiIxNzc1MDI0MTM1NjQ5XzIiLCJuYW1lIjoi55S15a2Q5Z+Owrflm73pmYXnlLXlrZDmgLvpg6giLCJsbmciOjExNi40OTAxLCJsYXQiOjM5Ljk4MzQ1N30seyJpZCI6IjE3NzUwMjQxMzU2NDlfMyIsIm5hbWUiOiLkuqzlv7HmtqbkuJoiLCJsbmciOjExNi41NjMzNzgsImxhdCI6MzkuODY4NjA2fSx7ImlkIjoiMTc3NTAyNDEzNTY0OV80IiwibmFtZSI6IuawuOWQiOmmqOiLkSIsImxuZyI6MTE2LjM5Njg2NCwibGF0IjozOS44NjM4Njl9LHsiaWQiOiIxNzc1MDI0MTM1NjQ5XzUiLCJuYW1lIjoi6J6N5a+TIiwibG5nIjoxMTYuMjgyOTE3LCJsYXQiOjM5Ljg1NzExOH0seyJpZCI6IjE3NzUwMjQxMzU2NDlfNiIsIm5hbWUiOiLplb/ovpvlupflm63mnpfnu7/ljJbnq5kiLCJsbmciOjExNi4xOTk0ODYsImxhdCI6MzkuODAxODQxfSx7ImlkIjoiMTc3NTAyNDEzNTY0OV83IiwibmFtZSI6IuawuOWumumVhyIsImxuZyI6MTE2LjA3NDI4NiwibGF0IjozOS45MDcwODl9XQ==-->',12,'https://java-ai--710.oss-cn-beijing.aliyuncs.com/files/img/1775024220790_27d763bd67eb4cfb87052291e9042ecc.png',2,'2026-04-01 14:17:22','2026-04-07 04:19:15');
/*!40000 ALTER TABLE `travel_guide` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄦ埛ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鍚?,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(鍔犲瘑瀛樺偍)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏄电О',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閭',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎵嬫満鍙?,
  `role_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'USER' COMMENT '瑙掕壊code',
  `avatar` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶村儚',
  `status` tinyint DEFAULT '1' COMMENT '鐘舵€?0:绂佺敤,1:姝ｅ父)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `sex` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎬у埆',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_username` (`username`) USING BTREE,
  UNIQUE KEY `uk_email` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄦ埛淇℃伅琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','$2a$10$09F04vxwj85zvZcMP0ig6.HTglDVh4Wd/AqstoIu86SjGmhEAfJBu','绠＄悊鍛?,'admin@tourism.com','13800138000','ADMIN','/img/1748599714053.jpg',1,'2025-05-14 10:00:00','2025-05-30 18:08:34','濂?),(2,'zhangsan','$2a$10$iul6jocLsH.A4gN1QUpgDexDq6KO89syHjUkRD3NbA1L6CTVrNRMO','寮犱笁','zhangsan@example.com','13712345678','USER','/img/1748492051307.jpg',1,'2025-05-14 10:01:00','2025-05-29 12:14:11','鐢?),(3,'lisi','$2a$10$iul6jocLsH.A4gN1QUpgDexDq6KO89syHjUkRD3NbA1L6CTVrNRMO','鏉庡洓','lisi@example.com','13812345679','USER','/img/1754194908839.jpg',1,'2025-05-14 10:02:00','2025-08-03 12:21:49','濂?),(4,'wangwu','$2a$10$iul6jocLsH.A4gN1QUpgDexDq6KO89syHjUkRD3NbA1L6CTVrNRMO','鐜嬩簲','wangwu@example.com','13912345670','USER','/img/avatar/user3.png',1,'2025-05-14 10:03:00','2025-05-14 10:03:00','鐢?),(5,'w11','$2a$10$PiiBwss6gAXqGs00nG8o6e1YzhPk.ikUI8Qf98KM3BT3DulvzYPyy','111','11111@qq.com','','USER',NULL,1,'2025-05-31 01:45:50','2025-05-31 01:45:50','鐢?),(6,'1796145608','$2a$10$7.DA4qkAKrtlaku9BBtcquqMbeH2dG4urusDoI3N1kAadKq7ttK5.',NULL,'1796145608@qq.com',NULL,'USER',NULL,1,'2025-06-19 21:11:58','2025-06-19 21:11:58',NULL),(7,'2075478343AkY','$2a$10$aTyJIJfNS47CvpYGWomBr.7l/yWkqsOZwV16V4wFSs6tpjYNTAvSm','','2075478343@qq.com','','USER',NULL,1,'2025-08-03 09:22:19','2025-08-03 09:22:19',NULL),(12,'demo_user','$2a$10$fxxU38CgddBR9Y.AsA2H1exb0y91yuSyGqPX1httoe9aqbQc2JKbm','','demo@example.com','','USER',NULL,1,'2026-03-27 02:23:32','2026-03-27 02:23:32',NULL);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-07 22:17:57


