! =============================================================================
! hdf5.f90 — LFortran-compilable stub for the HDF5 module
!
! Covers everything mglet-base uses from HDF5.
! Compile with lfortran to produce a lfortran-format .mod file used as a
! drop-in replacement for the system gfortran hdf5.mod.
! Actual HDF5 calls still link against the system HDF5 library.
! =============================================================================
MODULE hdf5
    USE, INTRINSIC :: ISO_C_BINDING
    IMPLICIT NONE

    ! ── Kind parameters ────────────────────────────────────────────────────────
    INTEGER, PARAMETER :: HID_T    = c_int64_t
    INTEGER, PARAMETER :: SIZE_T   = c_int64_t  ! HDF5 size type for strings/buffers
    INTEGER, PARAMETER :: HSIZE_T  = c_int64_t
    INTEGER, PARAMETER :: HSSIZE_T = c_int64_t

    ! ── H5 kind selector constants ─────────────────────────────────────────────
    INTEGER, PARAMETER :: H5_REAL_KIND    = 1
    INTEGER, PARAMETER :: H5_INTEGER_KIND = 0

    ! ── File access flags ──────────────────────────────────────────────────────
    INTEGER,        PARAMETER :: H5F_ACC_RDWR_F   = 1
    INTEGER,        PARAMETER :: H5F_ACC_RDONLY_F = 0
    INTEGER,        PARAMETER :: H5F_ACC_TRUNC_F  = 2

    ! ── Property list constants ────────────────────────────────────────────────
    INTEGER(HID_T), PARAMETER :: H5P_DEFAULT_F      = 0
    INTEGER(HID_T), PARAMETER :: H5P_FILE_ACCESS_F  = 1
    INTEGER(HID_T), PARAMETER :: H5P_DATASET_XFER_F = 2

    ! ── Dataspace constants ────────────────────────────────────────────────────
    INTEGER(HID_T), PARAMETER :: H5S_ALL_F        = 0
    INTEGER,        PARAMETER :: H5S_SELECT_SET_F = 0
    INTEGER,        PARAMETER :: H5S_SELECT_OR_F  = 1
    INTEGER,        PARAMETER :: H5S_SELECT_AND_F = 2
    INTEGER,        PARAMETER :: H5S_SELECT_XOR_F = 3
    INTEGER,        PARAMETER :: H5S_SELECT_NOTB_F= 4
    INTEGER,        PARAMETER :: H5S_SELECT_NOTA_F= 5

    ! MPI-IO transfer mode constants
    INTEGER, PARAMETER :: H5FD_MPIO_COLLECTIVE_F  = 0
    INTEGER, PARAMETER :: H5FD_MPIO_INDEPENDENT_F = 1

    ! ── Native type constants ──────────────────────────────────────────────────
    INTEGER(HID_T), PARAMETER :: H5T_NATIVE_REAL_F    = 0
    INTEGER(HID_T), PARAMETER :: H5T_NATIVE_DOUBLE_F  = 1
    INTEGER(HID_T), PARAMETER :: H5T_NATIVE_INTEGER_F = 2
    INTEGER(HID_T), PARAMETER :: H5T_STD_I64LE_F         = 3
    INTEGER(HID_T), PARAMETER :: H5T_NATIVE_CHARACTER       = 4

    ! ── H5F access/close constants ────────────────────────────────────────────
    INTEGER,        PARAMETER :: H5F_ACC_EXCL_F             = 3
    INTEGER,        PARAMETER :: H5F_CLOSE_SEMI_F           = 1
    INTEGER,        PARAMETER :: H5F_LIBVER_V110_F          = 2
    INTEGER,        PARAMETER :: H5F_LIBVER_LATEST_F        = 3
    INTEGER,        PARAMETER :: H5F_LIBVER_EARLIEST_F      = 0

    ! ── H5S dataspace constants ───────────────────────────────────────────────
    INTEGER,        PARAMETER :: H5S_SCALAR_F               = 0
    INTEGER(HSIZE_T), PARAMETER :: H5S_UNLIMITED_F          = -1

    ! ── H5P creation order constants ─────────────────────────────────────────
    INTEGER,        PARAMETER :: H5P_CRT_ORDER_TRACKED_F    = 1
    INTEGER,        PARAMETER :: H5P_CRT_ORDER_INDEXED_F    = 2

    ! ── H5T class constants ───────────────────────────────────────────────────
    INTEGER, PARAMETER :: H5T_COMPOUND_F  = 6
    INTEGER, PARAMETER :: H5T_STRING_F    = 3
    INTEGER, PARAMETER :: H5T_INTEGER_F   = 0
    INTEGER, PARAMETER :: H5T_FLOAT_F     = 1

    ! ── H5P class constants ───────────────────────────────────────────────────
    INTEGER(HID_T), PARAMETER :: H5P_DATASET_CREATE_F   = 3
    INTEGER(HID_T), PARAMETER :: H5P_LINK_CREATE_F      = 4
    INTEGER(HID_T), PARAMETER :: H5P_GROUP_CREATE_F     = 5
    ! removed duplicate: INTEGER(HID_T), PARAMETER :: H5F_CLOSE_SEMI_F       = 1
    ! removed duplicate: INTEGER(HID_T), PARAMETER :: H5F_LIBVER_LATEST_F    = 3
    ! removed duplicate: INTEGER(HID_T), PARAMETER :: H5F_LIBVER_EARLIEST_F  = 0
    ! removed duplicate: INTEGER(HID_T), PARAMETER :: H5P_CRT_ORDER_TRACKED_F = 1


    ! ── H5O info type (used by h5oget_info_f) ─────────────────────────────────
    TYPE :: h5o_info_t
        INTEGER(HID_T) :: fileno   = 0
        INTEGER(HID_T) :: addr     = 0
        INTEGER        :: type     = 0
        INTEGER        :: rc       = 0
        INTEGER(HID_T) :: atime    = 0
        INTEGER(HID_T) :: mtime    = 0
        INTEGER(HID_T) :: ctime    = 0
        INTEGER(HID_T) :: btime    = 0
        INTEGER(HSIZE_T) :: num_attrs = 0
    END TYPE h5o_info_t

    ! ── H5O/H5A iteration constants ────────────────────────────────────────────
    INTEGER, PARAMETER :: H5_INDEX_CRT_ORDER_F = 1
    INTEGER, PARAMETER :: H5_INDEX_NAME_F       = 0
    INTEGER, PARAMETER :: H5_ITER_INC_F         = 0
    INTEGER, PARAMETER :: H5_ITER_DEC_F         = 1
    INTEGER, PARAMETER :: H5_ITER_NATIVE_F      = 2

    ! ── Interfaces ─────────────────────────────────────────────────────────────
    INTERFACE
        SUBROUTINE h5fis_hdf5_f(name, status, hdferr)
            CHARACTER(LEN=*), INTENT(IN)  :: name
            LOGICAL,          INTENT(OUT) :: status
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5open_f(error)
            INTEGER, INTENT(OUT) :: error
        END SUBROUTINE

        SUBROUTINE h5close_f(error)
            INTEGER, INTENT(OUT) :: error
        END SUBROUTINE

        SUBROUTINE h5fcreate_f(name, access_flags, file_id, hdferr, &
                               creation_prp, access_prp)
            IMPORT :: HID_T
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER,          INTENT(IN)            :: access_flags
            INTEGER(HID_T),   INTENT(OUT)           :: file_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: creation_prp
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: access_prp
        END SUBROUTINE

        SUBROUTINE h5fopen_f(name, access_flags, file_id, hdferr, access_prp)
            IMPORT :: HID_T
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER,          INTENT(IN)            :: access_flags
            INTEGER(HID_T),   INTENT(OUT)           :: file_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: access_prp
        END SUBROUTINE

        SUBROUTINE h5fclose_f(file_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: file_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5dcreate_f(loc_id, name, type_id, space_id, dset_id, hdferr, &
                               dcpl_id, dapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER(HID_T),   INTENT(IN)            :: type_id
            INTEGER(HID_T),   INTENT(IN)            :: space_id
            INTEGER(HID_T),   INTENT(OUT)           :: dset_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: dcpl_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: dapl_id
        END SUBROUTINE

        SUBROUTINE h5dopen_f(loc_id, name, dset_id, hdferr, dapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER(HID_T),   INTENT(OUT)           :: dset_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: dapl_id
        END SUBROUTINE

        SUBROUTINE h5dclose_f(dset_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: dset_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

    END INTERFACE

    ! h5dread_f is generic in HDF5: a pointer form without dims and
    ! typed array forms that take dims
    INTERFACE h5dread_f
        SUBROUTINE h5dread_ptr(dset_id, mem_type_id, buf, hdferr, &
                               mem_space_id, file_space_id, xfer_prp)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: dset_id
            INTEGER(HID_T),   INTENT(IN)            :: mem_type_id
            TYPE(*), DIMENSION(..)                                :: buf
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: mem_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: file_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: xfer_prp
        END SUBROUTINE

        SUBROUTINE h5dread_array(dset_id, mem_type_id, buf, dims, hdferr, &
                                 mem_space_id, file_space_id, xfer_prp)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)            :: dset_id
            INTEGER(HID_T),   INTENT(IN)            :: mem_type_id
            TYPE(*), DIMENSION(..)                                :: buf
            INTEGER(HSIZE_T), INTENT(IN)            :: dims(:)
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: mem_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: file_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: xfer_prp
        END SUBROUTINE
    END INTERFACE

    INTERFACE

        SUBROUTINE h5dwrite_f(dset_id, mem_type_id, buf, hdferr, &
                               mem_space_id, file_space_id, xfer_prp)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: dset_id
            INTEGER(HID_T),   INTENT(IN)            :: mem_type_id
            TYPE(*), DIMENSION(..),          INTENT(IN)            :: buf
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: mem_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: file_space_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: xfer_prp
        END SUBROUTINE

        SUBROUTINE h5screate_simple_f(rank, dims, space_id, hdferr, maxdims)
            IMPORT :: HID_T, HSIZE_T
            INTEGER,          INTENT(IN)            :: rank
            INTEGER(HSIZE_T), INTENT(IN)            :: dims(rank)
            INTEGER(HID_T),   INTENT(OUT)           :: space_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HSIZE_T), INTENT(IN),  OPTIONAL :: maxdims(rank)
        END SUBROUTINE

        SUBROUTINE h5sclose_f(space_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: space_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5sselect_hyperslab_f(space_id, operator, start, count, &
                                         hdferr, stride, block)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)            :: space_id
            INTEGER,          INTENT(IN)            :: operator
            INTEGER(HSIZE_T), INTENT(IN)            :: start(:)
            INTEGER(HSIZE_T), INTENT(IN)            :: count(:)
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HSIZE_T), INTENT(IN),  OPTIONAL :: stride(:)
            INTEGER(HSIZE_T), INTENT(IN),  OPTIONAL :: block(:)
        END SUBROUTINE

        SUBROUTINE h5pcreate_f(cls_id, prp_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: cls_id
            INTEGER(HID_T), INTENT(OUT) :: prp_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pclose_f(prp_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: prp_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_fapl_mpio_f(prp_id, comm, info, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: prp_id
            INTEGER,        INTENT(IN)  :: comm
            INTEGER,        INTENT(IN)  :: info
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_dxpl_mpio_f(prp_id, data_xfer_mode, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: prp_id
            INTEGER,        INTENT(IN)  :: data_xfer_mode
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_coll_metadata_write_f(prp_id, flag, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: prp_id
            LOGICAL,        INTENT(IN)  :: flag
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        FUNCTION h5kind_to_type(kind, flag) RESULT(type_id)
            IMPORT :: HID_T
            INTEGER,        INTENT(IN) :: kind
            INTEGER,        INTENT(IN) :: flag
            INTEGER(HID_T)             :: type_id
        END FUNCTION

        SUBROUTINE h5gcreate_f(loc_id, name, grp_id, hdferr, &
                               size_hint, lcpl_id, gcpl_id, gapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER(HID_T),   INTENT(OUT)           :: grp_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER,          INTENT(IN),  OPTIONAL :: size_hint
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: lcpl_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: gcpl_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: gapl_id
        END SUBROUTINE

        SUBROUTINE h5gopen_f(loc_id, name, grp_id, hdferr, gapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER(HID_T),   INTENT(OUT)           :: grp_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: gapl_id
        END SUBROUTINE

        SUBROUTINE h5gclose_f(grp_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: grp_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5acreate_f(loc_id, name, type_id, space_id, attr_id, hdferr, &
                               acpl_id, aapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            INTEGER(HID_T),   INTENT(IN)            :: type_id
            INTEGER(HID_T),   INTENT(IN)            :: space_id
            INTEGER(HID_T),   INTENT(OUT)           :: attr_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: acpl_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: aapl_id
        END SUBROUTINE

        SUBROUTINE h5aopen_f(obj_id, attr_name, attr_id, hdferr, aapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: obj_id
            CHARACTER(LEN=*), INTENT(IN)            :: attr_name
            INTEGER(HID_T),   INTENT(OUT)           :: attr_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: aapl_id
        END SUBROUTINE

        SUBROUTINE h5aclose_f(attr_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: attr_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aread_f(attr_id, memtype_id, buf, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: attr_id
            INTEGER(HID_T),   INTENT(IN)  :: memtype_id
            TYPE(*), DIMENSION(..)                      :: buf
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5awrite_f(attr_id, memtype_id, buf, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: attr_id
            INTEGER(HID_T),   INTENT(IN)  :: memtype_id
            TYPE(*), DIMENSION(..),          INTENT(IN)  :: buf
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5lexists_f(loc_id, name, link_exists, hdferr, lapl_id)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: name
            LOGICAL,          INTENT(OUT)           :: link_exists
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: lapl_id
        END SUBROUTINE


        ! ── Additional type/property functions ───────────────────────────────
        SUBROUTINE h5tcreate_f(class, size, type_id, hdferr)
            IMPORT :: HID_T
            INTEGER,        INTENT(IN)  :: class
            INTEGER(HID_T), INTENT(IN)  :: size
            INTEGER(HID_T), INTENT(OUT) :: type_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tclose_f(type_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: type_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tcopy_f(type_id, new_type_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: type_id
            INTEGER(HID_T), INTENT(OUT) :: new_type_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tinsert_f(type_id, name, offset, field_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: type_id
            CHARACTER(LEN=*), INTENT(IN)  :: name
            INTEGER(HID_T),   INTENT(IN)  :: offset
            INTEGER(HID_T),   INTENT(IN)  :: field_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tset_size_f(type_id, size, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: type_id
            INTEGER(HID_T), INTENT(IN)  :: size
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tequal_f(type1_id, type2_id, flag, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: type1_id
            INTEGER(HID_T), INTENT(IN)  :: type2_id
            LOGICAL,        INTENT(OUT) :: flag
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tget_class_f(type_id, class, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: type_id
            INTEGER,        INTENT(OUT) :: class
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5dget_space_f(dataset_id, dataspace_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: dataset_id
            INTEGER(HID_T), INTENT(OUT) :: dataspace_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5dget_type_f(dataset_id, datatype_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: dataset_id
            INTEGER(HID_T), INTENT(OUT) :: datatype_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5dset_extent_f(dataset_id, size, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: dataset_id
            INTEGER(HSIZE_T), INTENT(IN)  :: size(:)
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5screate_f(classtype, space_id, hdferr)
            IMPORT :: HID_T
            INTEGER,        INTENT(IN)  :: classtype
            INTEGER(HID_T), INTENT(OUT) :: space_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5sget_simple_extent_dims_f(space_id, dims, maxdims, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: space_id
            INTEGER(HSIZE_T), INTENT(OUT) :: dims(:)
            INTEGER(HSIZE_T), INTENT(OUT) :: maxdims(:)
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aget_space_f(attr_id, space_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: attr_id
            INTEGER(HID_T), INTENT(OUT) :: space_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aget_type_f(attr_id, type_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: attr_id
            INTEGER(HID_T), INTENT(OUT) :: type_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5acreate_by_name_f(loc_id, obj_name, attr_name, &
                type_id, space_id, attr_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: loc_id
            CHARACTER(LEN=*), INTENT(IN)  :: obj_name
            CHARACTER(LEN=*), INTENT(IN)  :: attr_name
            INTEGER(HID_T),   INTENT(IN)  :: type_id
            INTEGER(HID_T),   INTENT(IN)  :: space_id
            INTEGER(HID_T),   INTENT(OUT) :: attr_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aopen_by_name_f(loc_id, obj_name, attr_name, &
                attr_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: loc_id
            CHARACTER(LEN=*), INTENT(IN)  :: obj_name
            CHARACTER(LEN=*), INTENT(IN)  :: attr_name
            INTEGER(HID_T),   INTENT(OUT) :: attr_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aexists_f(obj_id, attr_name, attr_exists, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: obj_id
            CHARACTER(LEN=*), INTENT(IN)  :: attr_name
            LOGICAL,          INTENT(OUT) :: attr_exists
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aexists_by_name_f(loc_id, obj_name, attr_name, &
                attr_exists, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: loc_id
            CHARACTER(LEN=*), INTENT(IN)  :: obj_name
            CHARACTER(LEN=*), INTENT(IN)  :: attr_name
            LOGICAL,          INTENT(OUT) :: attr_exists
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5oopen_f(loc_id, name, obj_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: loc_id
            CHARACTER(LEN=*), INTENT(IN)  :: name
            INTEGER(HID_T),   INTENT(OUT) :: obj_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5oclose_f(obj_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: obj_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5iget_name_f(obj_id, buf, buf_size, name_size, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: obj_id
            CHARACTER(LEN=*), INTENT(OUT) :: buf
            INTEGER(HID_T),   INTENT(IN)  :: buf_size
            INTEGER(HID_T),   INTENT(OUT) :: name_size
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5fget_name_f(obj_id, buf, size, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: obj_id
            CHARACTER(LEN=*), INTENT(OUT) :: buf
            INTEGER(HID_T),   INTENT(OUT) :: size
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_chunk_f(prp_id, ndims, dims, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: prp_id
            INTEGER,          INTENT(IN)  :: ndims
            INTEGER(HSIZE_T), INTENT(IN)  :: dims(ndims)
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_fclose_degree_f(fapl_id, degree, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: fapl_id
            INTEGER,        INTENT(IN)  :: degree
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_libver_bounds_f(fapl_id, low, high, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: fapl_id
            INTEGER,        INTENT(IN)  :: low
            INTEGER,        INTENT(IN)  :: high
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_link_creation_order_f(gcpl_id, crt_order_flags, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: gcpl_id
            INTEGER,        INTENT(IN)  :: crt_order_flags
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        ! ── Missing constants used via h5tcreate_f ────────────────────────────
        ! H5T_COMPOUND_F is a class constant, declared below in module body

        SUBROUTINE h5sselect_none_f(space_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: space_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5sselect_all_f(space_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: space_id
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5sget_select_npoints_f(space_id, npoints, hdferr)
            IMPORT :: HID_T, HSSIZE_T
            INTEGER(HID_T),    INTENT(IN)  :: space_id
            INTEGER(HSSIZE_T), INTENT(OUT) :: npoints
            INTEGER,           INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5sget_simple_extent_npoints_f(space_id, npoints, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: space_id
            INTEGER(HSIZE_T), INTENT(OUT) :: npoints
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5tarray_create_f(base_id, rank, dims, type_id, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: base_id
            INTEGER,          INTENT(IN)  :: rank
            INTEGER(HSIZE_T), INTENT(IN)  :: dims(:)
            INTEGER(HID_T),   INTENT(OUT) :: type_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5aget_name_f(attr_id, size, buf, hdferr)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)  :: attr_id
            INTEGER(HSIZE_T), INTENT(IN)  :: size
            CHARACTER(LEN=*), INTENT(OUT) :: buf
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5oget_info_f(object_id, object_info, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T), INTENT(IN)  :: object_id
            TYPE(*), DIMENSION(..)                    :: object_info
            INTEGER,        INTENT(OUT) :: hdferr
        END SUBROUTINE

        SUBROUTINE h5pset_virtual_f(dcpl_id, vspace_id, src_file_name, &
                src_dset_name, src_space_id, hdferr)
            IMPORT :: HID_T
            INTEGER(HID_T),   INTENT(IN)  :: dcpl_id
            INTEGER(HID_T),   INTENT(IN)  :: vspace_id
            CHARACTER(LEN=*), INTENT(IN)  :: src_file_name
            CHARACTER(LEN=*), INTENT(IN)  :: src_dset_name
            INTEGER(HID_T),   INTENT(IN)  :: src_space_id
            INTEGER,          INTENT(OUT) :: hdferr
        END SUBROUTINE



        FUNCTION H5OFFSETOF(base_ptr, member_ptr) RESULT(offset)
            IMPORT :: C_PTR, C_SIZE_T
            TYPE(C_PTR), INTENT(IN), VALUE :: base_ptr
            TYPE(C_PTR), INTENT(IN), VALUE :: member_ptr
            INTEGER(C_SIZE_T) :: offset
        END FUNCTION


        SUBROUTINE H5Aopen_by_idx_f(loc_id, obj_name, idx_type, order, &
                n, attr_id, hdferr, lapl_id, aapl_id)
            IMPORT :: HID_T, HSIZE_T
            INTEGER(HID_T),   INTENT(IN)            :: loc_id
            CHARACTER(LEN=*), INTENT(IN)            :: obj_name
            INTEGER,          INTENT(IN)            :: idx_type
            INTEGER,          INTENT(IN)            :: order
            INTEGER(HSIZE_T), INTENT(IN)            :: n
            INTEGER(HID_T),   INTENT(OUT)           :: attr_id
            INTEGER,          INTENT(OUT)           :: hdferr
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: lapl_id
            INTEGER(HID_T),   INTENT(IN),  OPTIONAL :: aapl_id
        END SUBROUTINE

    END INTERFACE

END MODULE hdf5
