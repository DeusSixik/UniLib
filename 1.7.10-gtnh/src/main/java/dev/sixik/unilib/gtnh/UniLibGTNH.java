package dev.sixik.unilib.gtnh;

import cpw.mods.fml.common.Mod;
import dev.sixik.unilib.UniLib;

/** Forge 1.7.10 entry point for the GTNH environment running on Java 21. */
@Mod(modid = UniLib.MOD_ID, name = UniLib.NAME, version = Tags.VERSION,
        acceptedMinecraftVersions = "[1.7.10]")
public final class UniLibGTNH {
    /** Creates the library mod on dedicated servers and clients. */
    public UniLibGTNH() {
    }
}
