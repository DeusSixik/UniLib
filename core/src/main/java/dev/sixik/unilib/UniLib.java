package dev.sixik.unilib;

/** Shared library identity, independent of Minecraft and its mod loaders. */
public final class UniLib {
    /** Stable lowercase mod identifier used by every supported loader. */
    public static final String MOD_ID = "unilib";

    /** Human-readable library name. */
    public static final String NAME = "UniLib";

    /** Prevents instantiation of the library constants. */
    private UniLib() {
    }
}
