--- Rarity Tweaks
--- Metadata lives in raritytweaks.json (Steamodded 1.0+ metadata format).
--- Do NOT re-add a `--- STEAMODDED HEADER` block here; having both is asking
--- for trouble, and the JSON is the supported path.

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
-- Keys are VANILLA joker keys with the "j_" prefix stripped.
--   j_hanging_chad -> hanging_chad
--   j_mail         -> mail
--
-- rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
--         (SMODS custom rarities can also be passed as a string key)
-- cost:   base shop price, before deck/voucher modifiers
--
-- Anything you can set on a Joker definition can go in here, not just
-- rarity/cost -- e.g. blueprint_compat, eternal_compat, unlocked, config.
----------------------------------------------------------------------

local overrides = {
    hanging_chad = { rarity = 2, cost = 6 },
    mail         = { rarity = 2, cost = 7 },
}

----------------------------------------------------------------------
-- APPLY
----------------------------------------------------------------------
-- take_ownership merges these fields into the existing center *before*
-- SMODS injects jokers into G.P_JOKER_RARITY_POOLS, so the pool membership,
-- the rarity badge, and the shop price all follow automatically.
--
-- This is why there are no Game:init_game_object / Game:start_run hooks
-- anymore: there is nothing left to re-apply after the fact.

local patched, failed = 0, 0

for key, props in pairs(overrides) do
    local ok, err = pcall(function()
        SMODS.Joker:take_ownership(key, props, true)
    end)

    if ok then
        patched = patched + 1
    else
        failed = failed + 1
        sendWarnMessage(
            ("could not patch joker 'j_%s': %s"):format(key, tostring(err)),
            "RarityTweaks"
        )
    end
end

sendInfoMessage(
    ("patched %d joker(s), %d failure(s)"):format(patched, failed),
    "RarityTweaks"
)
