function MoveLikeZombie()
  ps = Utils.AllPathablePoints(Me.Pos, Me.Pos, 2, 5)
  target = ps[Utils.Rand(table.getn(ps))]
  Do.Move({target}, 1000)
end

function GetTarget()
  targets = {"Table", "Mirror", "Chest"}
  for _, target in pairs(targets) do
    ents = Cheat.GetEntsByName(target)
    if table.getn(ents) > 0 then
      return ents[1]
    end
  end
  return nil
end

function CrushIntruder(debuf, cond, melee, ranged, aoe)
  enemies = Utils.NearestNEntities(3, "intruder")
  if table.getn(enemies) == 0 then
    return false
  end

  nearest = enemies[1]
  if aoe and Me.Actions[aoe].Ap > Me.ApCur then
    aoe_dist = Me.Actions[aoe].Range
    pos, ents = Utils.BestAoeAttackPos(aoe, 1, "minions ok")

    -- We can hit more than one entity so we'll go ahead and use our aoe
    if table.getn(ents) > 1 then
      ps = Utils.AllPathablePoints(Me.Pos, pos, 1, aoe_dist)
      Do.Move(ps, 1000)
      Do.AoeAttack(aoe, pos)
    end
  end

  attack = ranged
  if not attack then
    attack = melee
  end
  max_dist = Me.Actions[attack].Range
  lowest_hp = 10000
  lowest_ent = nil
  for i, enemy in pairs(enemies) do
    dist = Utils.RangedDistBetweenEntities(Me, enemy)
    if dist and dist <= max_dist and enemy.HpCur < lowest_hp then
      lowest_hp = enemy.HpCur
      lowest_ent = enemy
    end
  end
  if lowest_ent == nil and table.getn(enemies) > 0 then
    min = Me.Actions[attack].Range - 2
    if min < 1 then
      min = 1
    end
    ps = Utils.AllPathablePoints(Me.Pos, enemies[1].Pos, min, Me.Actions[attack].Range)
    if table.getn(ps) > 0 then
      return Do.Move(ps, 1000)
    end
  end
  target = lowest_ent
  dist = Utils.RangedDistBetweenEntities(Me, target)
  if not dist then
    return false
  end
  if debuf and cond and not target.Conditions[cond] and dist <= Me.Actions[debuf].Range then
    return Do.BasicAttack(debuf, target)
  end
  attack = ranged
  if dist == 1 then
    attack = melee
  end
  return Do.BasicAttack(attack, target)
end

