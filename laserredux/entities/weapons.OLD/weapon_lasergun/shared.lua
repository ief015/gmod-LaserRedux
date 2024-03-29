local shotnumber=0;

if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	SWEP.PrintName = "Mini-Laser Gun"
	SWEP.Author	= "rcdraco"
	SWEP.Slot = 4
	SWEP.SlotPos = 0
	SWEP.IconLetter = "c"
	SWEP.ViewModelFlip = false
	killicon.AddFont("Laser Gun", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound		= Sound("weapons/ar1/ar1_dist1.wav")
SWEP.Primary.Recoil		= .01
SWEP.Primary.Damage		= 1000 -- LOL!
SWEP.Primary.NumShots		= 10
SWEP.Primary.Cone		= 0.05
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay		= 0.03
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "pistol"


SWEP.Secondary.Sound		= Sound("npc/sniper/sniper1.wav")
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Recoil		= .01
SWEP.Secondary.Damage		= 1000 -- LOL!
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone		= 0.05
SWEP.Secondary.ClipSize		= 12
SWEP.Secondary.Delay		= 0.03
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.NextFire = 0
SWEP.Kickback = 50 -- This many units back.

-- Laser effect
function SWEP:ShootLaser(startp,endp,ang)
	local effect = EffectData()
	effect:SetStart(endp)
	effect:SetOrigin(startp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	local effect = EffectData()
	effect:SetStart(startp)
	effect:SetOrigin(endp)
	effect:SetEntity(self.Owner)
	util.Effect("laser",effect)
	
	util.BlastDamage(self.Weapon,self.Owner,endp,16,self.Primary.Damage)
end

-- Tell us to draw a bar
function SWEP:SendProgBar(endt)
	if SERVER then
		umsg.Start("laser_progbar",self.Owner)
		umsg.String(CurTime())
		umsg.String(CurTime() + endt)
		umsg.End()
	end
end

-- High Power Beam
function SWEP:PrimaryAttack()
	if CurTime() > self.NextFire then
		self.Owner:LagCompensation(true)
		self.Weapon:EmitSound(self.Primary.Sound,120,60)
		
		local tr = util.GetPlayerTrace(self.Owner,self.Owner:GetAimVector())
		local tr = util.TraceLine(tr)
		
		self:ShootLaser(self.Owner:GetShootPos() - Vector(0,5,10), tr.HitPos, self.Owner:GetAimVector())
		
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.NextFire = CurTime() + self.Primary.Delay

		shotnumber=shotnumber+1
		
		if(shotnumber==30) then
			self:SendProgBar(self.Primary.Delay * 250)
			self.NextFire = CurTime() + (self.Primary.Delay * 250)
			shotnumber=0;
		end

		if SERVER then
			self.Owner:SetVelocity((self.Owner:GetAimVector() * -1) * self.Kickback)
		end
		self.Owner:LagCompensation(false)
	end
end

SWEP.MaxShots = 12
SWEP.MaxOff = 0.15

SWEP.ShotgunSound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")

-- Secondary attack is a placeholder until I determine a fair way for this weapon to be balanced
function SWEP:SecondaryAttack()
	//Do Nothing
end

-- ! CLientside stuff --
-- Retrieve umsg for bar

function RetrieveProgBar(msg)
	if CLIENT then
		Freeze = tonumber(msg:ReadString())
		End = tonumber(msg:ReadString())
		DrawingBar = true
	end
end
usermessage.Hook("laser_progbar",RetrieveProgBar)

function SWEP:DrawHUD()
	if DrawingBar then
		if CurTime() < End then
			local scale = (CurTime() - Freeze) / (End - Freeze)
			
			draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, ScrW() * 0.4, ScrH() * 0.04, Color(100,100,100,255))
			draw.RoundedBox(8, ScrW() * 0.3, ScrH() * 0.04, (ScrW() * 0.4) * scale, ScrH() * 0.04, Color(0,100,0,255))
			draw.SimpleText("Recharging", "Font_40", ScrW() * 0.5, ScrH() * 0.04, Color(255,255,255,255), 1)
		else
			DrawingBar = false
		end
	end
end
		
	
		
