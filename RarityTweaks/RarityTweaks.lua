--- STEAMODDED HEADER
--- MOD_NAME: Rarity Tweaks
--- MOD_ID: raritytweaks
--- MOD_AUTHOR: Birbivore
--- MOD_DESCRIPTION: Changes Hanging Chad and Mail-In Rebate from Common to Uncommon.
--- PREFIX: raritytweaks
--- VERSION: 1.1.0

----------------------------------------------
------------ MOD CODE -------------------------

-- Balatro rarity values: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
local card_overrides = {
    j_hanging_chad = { rarity = 2, cost = 6 },   -- Hanging Chad: Common -> Uncommon, $6
    j_mail         = { rarity = 2, cost = 7 },   -- Mail-In Rebate: Common -> Uncommon, $7
}

-- Removes a center key from a rarity-indexed pool table (G.P_JOKER_RARITY_POOLS[rarity]),
-- wherever it currently sits, regardless of what rarity it was registered under.
local function remove_from_all_rarity_pools(key)
    if not G.P_JOKER_RARITY_POOLS then return end
    for rarity_key, pool in pairs(G.P_JOKER_RARITY_POOLS) do
        for i = #pool, 1, -1 do
            if pool[i] == key or (type(pool[i]) == "table" and pool[i].key == key) then
                table.remove(pool, i)
            end
        end
    end
end

-- Adds a center key into the correct rarity-indexed pool table.
local function add_to_rarity_pool(key, rarity)
    if not G.P_JOKER_RARITY_POOLS then return end
    G.P_JOKER_RARITY_POOLS[rarity] = G.P_JOKER_RARITY_POOLS[rarity] or {}
    table.insert(G.P_JOKER_RARITY_POOLS[rarity], key)
end

-- Patches both the center's own rarity/cost fields (for display + shop price)
-- AND its membership in the rarity pool tables (for actual draw odds).
local function apply_card_overrides()
    if not G.P_JOKER_RARITY_POOLS then
        sendWarnMessage("RarityTweaks: G.P_JOKER_RARITY_POOLS not ready yet, skipping this pass.", "RarityTweaks")
        return
    end
    for key, overrides in pairs(card_overrides) do
        local center = G.P_CENTERS[key]
        if center then
            center.rarity = overrides.rarity
            center.cost = overrides.cost

            remove_from_all_rarity_pools(key)
            add_to_rarity_pool(key, overrides.rarity)
        else
            sendWarnMessage("RarityTweaks: could not find center '" .. key .. "' to patch.", "RarityTweaks")
        end
    end
end

-- G.P_CENTERS and G.P_JOKER_RARITY_POOLS are populated during game init,
-- so we hook into the function that runs right after all core/base
-- jokers (and their pools) are loaded.
local ref_init_game_object = Game.init_game_object
function Game:init_game_object(...)
    local ret = ref_init_game_object(self, ...)
    apply_card_overrides()
    return ret
end

-- Belt-and-suspenders: pools can also get rebuilt/refreshed when a run
-- starts (new seed, new deck, etc.), so we re-apply right before a run
-- begins too, in case init_game_object fires too early relative to
-- pool construction.
local ref_start_run = Game.start_run
function Game:start_run(...)
    apply_card_overrides()
    return ref_start_run(self, ...)
end
