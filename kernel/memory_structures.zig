pub const GDTD = packed struct {
    size: u16,
    offset: u64,
};

pub const GDTE = packed struct {
    limit1: u16,
    base1: u16,
    base2: u8,
    accessed: u1,
    read_write: u1,
    dir_conforming: u1,
    code: u1,
    descriptor: u1,
    ring: u2,
    present: u1,
    limit2: u4,
    nullbits: u2,
    size: u1,
    granularity: u1,
    base3: u8,
};
