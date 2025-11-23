-- Fix quiz_completed status for users who already have character assigned
-- Run this script to update existing users who completed personality test

-- Step 1: Find users who have personality test results but quiz_completed is still false
SELECT 
    u.id,
    u.username,
    u.character_id,
    u.quiz_completed,
    ptr.assigned_character_id,
    c.name as character_name
FROM users u
LEFT JOIN personality_test_results ptr ON u.id = ptr.user_id
LEFT JOIN characters c ON ptr.assigned_character_id = c.id
WHERE ptr.id IS NOT NULL AND u.quiz_completed = false;

-- Step 2: Update users.quiz_completed = true for users who have completed personality test
UPDATE users u
SET 
    quiz_completed = true,
    character_id = ptr.assigned_character_id,
    updated_at = NOW()
FROM personality_test_results ptr
WHERE u.id = ptr.user_id 
  AND ptr.assigned_character_id IS NOT NULL
  AND u.quiz_completed = false;

-- Step 3: Verify the update
SELECT 
    u.id,
    u.username,
    u.character_id,
    u.quiz_completed,
    c.name as character_name
FROM users u
LEFT JOIN characters c ON u.character_id = c.id
WHERE u.id IN (
    SELECT user_id FROM personality_test_results WHERE assigned_character_id IS NOT NULL
);

-- Optional: If you need to reprocess a specific user's personality test
-- Uncomment and replace <user_id> with actual UUID
-- SELECT process_personality_test('<user_id>');
