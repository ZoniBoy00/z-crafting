-- Z-Crafting Installation Script
-- This ensures that the required metadata fields exist in the players table
-- QBox Framework stores crafting data in player metadata, which is automatically saved to the database

-- Note: QBox handles metadata automatically, but we create a dedicated table for tracking and statistics
CREATE TABLE IF NOT EXISTS `z_crafting_stats` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `crafting_level` INT DEFAULT 1,
    `crafting_xp` INT DEFAULT 0,
    `total_crafted` INT DEFAULT 0,
    `last_craft` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional: Portable table tracking (for persistence across restarts)
CREATE TABLE IF NOT EXISTS `z_crafting_tables` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `coords` VARCHAR(255) NOT NULL,
    `heading` FLOAT DEFAULT 0.0,
    `owner` VARCHAR(50) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
