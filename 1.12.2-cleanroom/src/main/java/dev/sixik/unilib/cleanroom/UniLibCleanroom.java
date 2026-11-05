package dev.sixik.unilib.cleanroom;

import dev.sixik.unilib.UniLib;
import net.minecraftforge.fml.common.Mod;

/** Forge 1.12.2 entry point for the Cleanroom environment running on Java 25. */
@Mod(modid = UniLib.MOD_ID, name = UniLib.NAME, useMetadata = true,
        acceptedMinecraftVersions = "[1.12.2]", acceptableRemoteVersions = "*")
public final class UniLibCleanroom {
    /** Creates the library mod on dedicated servers and clients. */
    public UniLibCleanroom() {
    }
}
