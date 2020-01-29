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

pub const CR3 = packed struct {
    PCID: u12,
    address: u42,
    nullbits: u10,
};

pub const PML4E = packed struct {
    present: u1,
    RW: u1,
    supervisor: u1,
    write_through: u1,
    cache_disabled: u1,
    accessed: u1,
    ignored: u1,
    nullbits_flg: u5,
    address: u42,
    nullbits: u9,
    execution_disabled: u1,
};

pub const PDPTE = packed struct {
    present: u1,
    RW: u1,
    supervisor: u1,
    write_through: u1,
    cache_disabled: u1,
    accessed: u1,
    ignored: u1,
    nullbits_flg: u5,
    address: u42,
    nullbits: u9,
    execution_disabled: u1,
};

pub const PDE = packed struct {
    present: u1,
    RW: u1,
    supervisor: u1,
    write_through: u1,
    cache_disabled: u1,
    accessed: u1,
    ignored: u1,
    nullbits_flg: u5,
    address: u42,
    nullbits: u9,
    execution_disabled: u1,
};

pub const PTE = packed struct {
    present: u1,
    RW: u1,
    supervisor: u1,
    write_through: u1,
    cache_disabled: u1,
    accessed: u1,
    dirty: u1,
    global: u1,
    nullbits_flg: u4,
    address: u42,
    nullbits: u9,
    execution_disabled: u1,
};
