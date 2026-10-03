! =============================================================================
! mpi_f08.f90 — LFortran-compilable stub for the MPI_f08 module
!
! Covers everything mglet-base src/core uses from MPI_f08.
! Compile with lfortran to produce a lfortran-format .mod file.
! Actual MPI calls still link against the system Open MPI library.
! =============================================================================
MODULE mpi_f08
    USE, INTRINSIC :: ISO_C_BINDING
    IMPLICIT NONE

    ! ── Derived types ──────────────────────────────────────────────────────────
    TYPE :: MPI_Datatype
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Datatype

    TYPE :: MPI_Comm
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Comm

    TYPE :: MPI_Op
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Op

    TYPE :: MPI_Status
        INTEGER :: MPI_SOURCE = 0
        INTEGER :: MPI_TAG    = 0
        INTEGER :: MPI_ERROR  = 0
    END TYPE MPI_Status

    TYPE :: MPI_Request
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Request

    TYPE :: MPI_Info
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Info

    TYPE :: MPI_Errhandler
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Errhandler

    TYPE :: MPI_Win
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Win

    ! MPI_Aint — address-sized integer kind
    INTEGER, PARAMETER :: MPI_ADDRESS_KIND = 8

    ! MPI_Aint as a predefined datatype (used in MPI_Allreduce etc.)
    TYPE(MPI_Datatype), PARAMETER :: MPI_Aint = MPI_Datatype(7)

    ! ── Communicators ──────────────────────────────────────────────────────────
    TYPE(MPI_Comm), PARAMETER :: MPI_COMM_WORLD = MPI_Comm(0)
    TYPE(MPI_Comm), PARAMETER :: MPI_COMM_NULL  = MPI_Comm(-1)

    ! ── Windows ────────────────────────────────────────────────────────────────
    TYPE(MPI_Win), PARAMETER :: MPI_WIN_NULL = MPI_Win(-1)

    ! ── Datatypes ──────────────────────────────────────────────────────────────
    TYPE(MPI_Datatype), PARAMETER :: MPI_BYTE             = MPI_Datatype(-1)
    TYPE(MPI_Datatype), PARAMETER :: MPI_REAL             = MPI_Datatype(0)
    TYPE(MPI_Datatype), PARAMETER :: MPI_DOUBLE_PRECISION  = MPI_Datatype(1)
    TYPE(MPI_Datatype), PARAMETER :: MPI_INTEGER           = MPI_Datatype(2)
    TYPE(MPI_Datatype), PARAMETER :: MPI_INTEGER8          = MPI_Datatype(3)
    TYPE(MPI_Datatype), PARAMETER :: MPI_LOGICAL           = MPI_Datatype(4)
    TYPE(MPI_Datatype), PARAMETER :: MPI_CHARACTER         = MPI_Datatype(5)
    TYPE(MPI_Datatype), PARAMETER :: MPI_REAL8             = MPI_Datatype(6)

    ! ── Operators ──────────────────────────────────────────────────────────────
    TYPE(MPI_Op), PARAMETER :: MPI_SUM = MPI_Op(0)
    TYPE(MPI_Op), PARAMETER :: MPI_MAX = MPI_Op(1)
    TYPE(MPI_Op), PARAMETER :: MPI_MIN = MPI_Op(2)

    ! ── Requests / info ────────────────────────────────────────────────────────
    TYPE(MPI_Request), PARAMETER :: MPI_REQUEST_NULL = MPI_Request(-1)
    TYPE(MPI_Info),    PARAMETER :: MPI_INFO_NULL    = MPI_Info(-1)

    ! ── Integer constants ──────────────────────────────────────────────────────
    INTEGER, PARAMETER :: MPI_SUCCESS                  = 0
    INTEGER, PARAMETER :: MPI_UNDEFINED                = -32766
    INTEGER, PARAMETER :: MPI_PROC_NULL                = -1
    INTEGER, PARAMETER :: MPI_COMM_TYPE_SHARED         = 1
    INTEGER, PARAMETER :: MPI_MAX_ERROR_STRING         = 512
    INTEGER, PARAMETER :: MPI_MAX_LIBRARY_VERSION_STRING = 8192

    ! ── Sentinels ──────────────────────────────────────────────────────────────
    TYPE(MPI_Status), TARGET :: MPI_STATUS_IGNORE
    TYPE(MPI_Status), TARGET :: MPI_STATUSES_IGNORE(1)

    ! MPI_IN_PLACE — special send buffer sentinel; represented as integer here.
    ! mglet passes it as the sendbuf argument in MPI_Allreduce etc.
    INTEGER, PARAMETER :: MPI_IN_PLACE = -1

    ! ── Abstract interface for user-defined MPI error handler ─────────────────
    ABSTRACT INTERFACE
        SUBROUTINE MPI_User_function(invec, inoutvec, len, datatype)
            IMPORT :: MPI_Datatype
            TYPE(*), INTENT(IN)    :: invec
            TYPE(*), INTENT(INOUT) :: inoutvec
            INTEGER, INTENT(IN)    :: len
            TYPE(MPI_Datatype), INTENT(IN) :: datatype
        END SUBROUTINE

        SUBROUTINE MPI_Comm_errhandler_function(comm, error_code)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm) :: comm
            INTEGER        :: error_code
        END SUBROUTINE
    END INTERFACE

    ! ── Subroutine / function interfaces ───────────────────────────────────────
    INTERFACE
        SUBROUTINE MPI_Init(ierror)
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Finalize(ierror)
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Abort(comm, errorcode, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER,        INTENT(IN)  :: errorcode
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_rank(comm, rank, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER,        INTENT(OUT) :: rank
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_size(comm, size, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER,        INTENT(OUT) :: size
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_dup(comm, newcomm, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            TYPE(MPI_Comm), INTENT(OUT) :: newcomm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_free(comm, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(INOUT) :: comm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_split(comm, color, key, newcomm, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER,        INTENT(IN)  :: color
            INTEGER,        INTENT(IN)  :: key
            TYPE(MPI_Comm), INTENT(OUT) :: newcomm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_split_type(comm, split_type, key, info, newcomm, ierror)
            IMPORT :: MPI_Comm, MPI_Info
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER,        INTENT(IN)  :: split_type
            INTEGER,        INTENT(IN)  :: key
            TYPE(MPI_Info), INTENT(IN)  :: info
            TYPE(MPI_Comm), INTENT(OUT) :: newcomm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_create_errhandler(comm_errhandler_fn, errhandler, ierror)
            IMPORT :: MPI_Errhandler, MPI_Comm_errhandler_function
            PROCEDURE(MPI_Comm_errhandler_function) :: comm_errhandler_fn
            TYPE(MPI_Errhandler), INTENT(OUT) :: errhandler
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Comm_set_errhandler(comm, errhandler, ierror)
            IMPORT :: MPI_Comm, MPI_Errhandler
            TYPE(MPI_Comm),       INTENT(IN)  :: comm
            TYPE(MPI_Errhandler), INTENT(IN)  :: errhandler
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Errhandler_free(errhandler, ierror)
            IMPORT :: MPI_Errhandler
            TYPE(MPI_Errhandler), INTENT(INOUT) :: errhandler
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Error_class(errorcode, errorclass, ierror)
            INTEGER, INTENT(IN)  :: errorcode
            INTEGER, INTENT(OUT) :: errorclass
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Error_string(errorcode, string, resultlen, ierror)
            INTEGER,          INTENT(IN)  :: errorcode
            CHARACTER(LEN=*), INTENT(OUT) :: string
            INTEGER,          INTENT(OUT) :: resultlen
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Get_library_version(version, resultlen, ierror)
            CHARACTER(LEN=*), INTENT(OUT) :: version
            INTEGER,          INTENT(OUT) :: resultlen
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Barrier(comm, ierror)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Bcast(buffer, count, datatype, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(INOUT) :: buffer
            INTEGER,            INTENT(IN)    :: count
            TYPE(MPI_Datatype), INTENT(IN)    :: datatype
            INTEGER,            INTENT(IN)    :: root
            TYPE(MPI_Comm),     INTENT(IN)    :: comm
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Send(buf, count, datatype, dest, tag, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            INTEGER,            INTENT(IN)  :: dest
            INTEGER,            INTENT(IN)  :: tag
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Recv(buf, count, datatype, source, tag, comm, status, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm, MPI_Status
            TYPE(*), DIMENSION(..)                        :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            INTEGER,            INTENT(IN)  :: source
            INTEGER,            INTENT(IN)  :: tag
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            TYPE(MPI_Status),   INTENT(OUT) :: status
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Isend(buf, count, datatype, dest, tag, comm, request, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm, MPI_Request
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            INTEGER,            INTENT(IN)  :: dest
            INTEGER,            INTENT(IN)  :: tag
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            TYPE(MPI_Request),  INTENT(OUT) :: request
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Irecv(buf, count, datatype, source, tag, comm, request, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm, MPI_Request
            TYPE(*), DIMENSION(..)                        :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            INTEGER,            INTENT(IN)  :: source
            INTEGER,            INTENT(IN)  :: tag
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            TYPE(MPI_Request),  INTENT(OUT) :: request
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Wait(request, status, ierror)
            IMPORT :: MPI_Request, MPI_Status
            TYPE(MPI_Request), INTENT(INOUT) :: request
            TYPE(MPI_Status),  INTENT(OUT)   :: status
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Waitall(count, array_of_requests, array_of_statuses, ierror)
            IMPORT :: MPI_Request, MPI_Status
            INTEGER,           INTENT(IN)    :: count
            TYPE(MPI_Request), INTENT(INOUT) :: array_of_requests(count)
            TYPE(MPI_Status),  INTENT(OUT)   :: array_of_statuses(count)
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Waitany(count, array_of_requests, index, status, ierror)
            IMPORT :: MPI_Request, MPI_Status
            INTEGER,           INTENT(IN)    :: count
            TYPE(MPI_Request), INTENT(INOUT) :: array_of_requests(count)
            INTEGER,           INTENT(OUT)   :: index
            TYPE(MPI_Status),  INTENT(OUT)   :: status
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Reduce(sendbuf, recvbuf, count, datatype, op, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Op, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            TYPE(MPI_Op),       INTENT(IN)  :: op
            INTEGER,            INTENT(IN)  :: root
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Allreduce(sendbuf, recvbuf, count, datatype, op, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Op, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            TYPE(MPI_Op),       INTENT(IN)  :: op
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Gather(sendbuf, sendcount, sendtype, recvbuf, &
                              recvcount, recvtype, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcount
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            INTEGER,            INTENT(IN)  :: root
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Gatherv(sendbuf, sendcount, sendtype, recvbuf, &
                               recvcounts, displs, recvtype, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcounts(*)
            INTEGER,            INTENT(IN)  :: displs(*)
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            INTEGER,            INTENT(IN)  :: root
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Scatter(sendbuf, sendcount, sendtype, recvbuf, &
                               recvcount, recvtype, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcount
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            INTEGER,            INTENT(IN)  :: root
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Scatterv(sendbuf, sendcounts, displs, sendtype, recvbuf, &
                                recvcount, recvtype, root, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcounts(*)
            INTEGER,            INTENT(IN)  :: displs(*)
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcount
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            INTEGER,            INTENT(IN)  :: root
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Allgather(sendbuf, sendcount, sendtype, recvbuf, &
                                 recvcount, recvtype, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcount
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Allgatherv(sendbuf, sendcount, sendtype, recvbuf, &
                                  recvcounts, displs, recvtype, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcounts(*)
            INTEGER,            INTENT(IN)  :: displs(*)
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Alltoall(sendbuf, sendcount, sendtype, recvbuf, &
                                recvcount, recvtype, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcount
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcount
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Alltoallv(sendbuf, sendcounts, sdispls, sendtype, &
                                 recvbuf, recvcounts, rdispls, recvtype, comm, ierror)
            IMPORT :: MPI_Datatype, MPI_Comm
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: sendbuf
            INTEGER,            INTENT(IN)  :: sendcounts(*)
            INTEGER,            INTENT(IN)  :: sdispls(*)
            TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
            TYPE(*), DIMENSION(..)                        :: recvbuf
            INTEGER,            INTENT(IN)  :: recvcounts(*)
            INTEGER,            INTENT(IN)  :: rdispls(*)
            TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
            TYPE(MPI_Comm),     INTENT(IN)  :: comm
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Get_address(location, address, ierror)
            TYPE(*), DIMENSION(..),    INTENT(IN)  :: location
            INTEGER(8), INTENT(OUT) :: address
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Get_count(status, datatype, count, ierror)
            IMPORT :: MPI_Status, MPI_Datatype
            TYPE(MPI_Status),   INTENT(IN)  :: status
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            INTEGER,            INTENT(OUT) :: count
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_contiguous(count, oldtype, newtype, ierror)
            IMPORT :: MPI_Datatype
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: oldtype
            TYPE(MPI_Datatype), INTENT(OUT) :: newtype
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_indexed(count, array_of_blocklengths, &
                                    array_of_displacements, oldtype, newtype, ierror)
            IMPORT :: MPI_Datatype
            INTEGER,            INTENT(IN)  :: count
            INTEGER,            INTENT(IN)  :: array_of_blocklengths(count)
            INTEGER,            INTENT(IN)  :: array_of_displacements(count)
            TYPE(MPI_Datatype), INTENT(IN)  :: oldtype
            TYPE(MPI_Datatype), INTENT(OUT) :: newtype
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_create_struct(count, array_of_blocklengths, &
                array_of_displacements, array_of_types, newtype, ierror)
            IMPORT :: MPI_Datatype
            INTEGER,            INTENT(IN)  :: count
            INTEGER,            INTENT(IN)  :: array_of_blocklengths(count)
            INTEGER(8),         INTENT(IN)  :: array_of_displacements(count)
            TYPE(MPI_Datatype), INTENT(IN)  :: array_of_types(count)
            TYPE(MPI_Datatype), INTENT(OUT) :: newtype
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_create_subarray(ndims, array_of_sizes, &
                array_of_subsizes, array_of_starts, order, oldtype, newtype, ierror)
            IMPORT :: MPI_Datatype
            INTEGER,            INTENT(IN)  :: ndims
            INTEGER,            INTENT(IN)  :: array_of_sizes(ndims)
            INTEGER,            INTENT(IN)  :: array_of_subsizes(ndims)
            INTEGER,            INTENT(IN)  :: array_of_starts(ndims)
            INTEGER,            INTENT(IN)  :: order
            TYPE(MPI_Datatype), INTENT(IN)  :: oldtype
            TYPE(MPI_Datatype), INTENT(OUT) :: newtype
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_commit(datatype, ierror)
            IMPORT :: MPI_Datatype
            TYPE(MPI_Datatype), INTENT(INOUT) :: datatype
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_free(datatype, ierror)
            IMPORT :: MPI_Datatype
            TYPE(MPI_Datatype), INTENT(INOUT) :: datatype
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_get_extent(datatype, lb, extent, ierror)
            IMPORT :: MPI_Datatype, MPI_ADDRESS_KIND
            TYPE(MPI_Datatype),             INTENT(IN)  :: datatype
            INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: lb
            INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: extent
            INTEGER, OPTIONAL,              INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Type_create_resized(oldtype, lb, extent, newtype, ierror)
            IMPORT :: MPI_Datatype, MPI_ADDRESS_KIND
            TYPE(MPI_Datatype),             INTENT(IN)  :: oldtype
            INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN)  :: lb
            INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN)  :: extent
            TYPE(MPI_Datatype),             INTENT(OUT) :: newtype
            INTEGER, OPTIONAL,              INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Op_create(user_fn, commute, op, ierror)
            IMPORT :: MPI_Op
            INTEGER,      INTENT(IN)  :: user_fn
            LOGICAL,      INTENT(IN)  :: commute
            TYPE(MPI_Op), INTENT(OUT) :: op
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Op_free(op, ierror)
            IMPORT :: MPI_Op
            TYPE(MPI_Op), INTENT(INOUT) :: op
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_File_open(comm, filename, amode, info, fh, ierror)
            IMPORT :: MPI_Comm, MPI_Info
            TYPE(MPI_Comm),   INTENT(IN)  :: comm
            CHARACTER(LEN=*), INTENT(IN)  :: filename
            INTEGER,          INTENT(IN)  :: amode
            TYPE(MPI_Info),   INTENT(IN)  :: info
            INTEGER,          INTENT(OUT) :: fh
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_File_close(fh, ierror)
            INTEGER, INTENT(INOUT) :: fh
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_File_read_at(fh, offset, buf, count, datatype, status, ierror)
            IMPORT :: MPI_Datatype, MPI_Status
            INTEGER,            INTENT(IN)  :: fh
            INTEGER,            INTENT(IN)  :: offset
            TYPE(*), DIMENSION(..)                        :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            TYPE(MPI_Status),   INTENT(OUT) :: status
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_File_write_at(fh, offset, buf, count, datatype, status, ierror)
            IMPORT :: MPI_Datatype, MPI_Status
            INTEGER,            INTENT(IN)  :: fh
            INTEGER,            INTENT(IN)  :: offset
            TYPE(*), DIMENSION(..),            INTENT(IN)  :: buf
            INTEGER,            INTENT(IN)  :: count
            TYPE(MPI_Datatype), INTENT(IN)  :: datatype
            TYPE(MPI_Status),   INTENT(OUT) :: status
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_File_set_view(fh, disp, etype, filetype, datarep, info, ierror)
            IMPORT :: MPI_Datatype, MPI_Info
            INTEGER,            INTENT(IN)  :: fh
            INTEGER,            INTENT(IN)  :: disp
            TYPE(MPI_Datatype), INTENT(IN)  :: etype
            TYPE(MPI_Datatype), INTENT(IN)  :: filetype
            CHARACTER(LEN=*),   INTENT(IN)  :: datarep
            TYPE(MPI_Info),     INTENT(IN)  :: info
            INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Win_allocate_shared(size, disp_unit, info, comm, baseptr, win, ierror)
            IMPORT :: MPI_Info, MPI_Comm, MPI_Win, c_ptr
            INTEGER(8),     INTENT(IN)  :: size
            INTEGER,        INTENT(IN)  :: disp_unit
            TYPE(MPI_Info), INTENT(IN)  :: info
            TYPE(MPI_Comm), INTENT(IN)  :: comm
            TYPE(c_ptr),    INTENT(OUT) :: baseptr
            TYPE(MPI_Win),  INTENT(OUT) :: win
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Win_shared_query(win, rank, size, disp_unit, baseptr, ierror)
            IMPORT :: MPI_Win, c_ptr
            TYPE(MPI_Win), INTENT(IN)  :: win
            INTEGER,       INTENT(IN)  :: rank
            INTEGER(8),    INTENT(OUT) :: size
            INTEGER,       INTENT(OUT) :: disp_unit
            TYPE(c_ptr),   INTENT(OUT) :: baseptr
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Win_fence(assert, win, ierror)
            IMPORT :: MPI_Win
            INTEGER,       INTENT(IN)  :: assert
            TYPE(MPI_Win), INTENT(IN)  :: win
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        SUBROUTINE MPI_Win_free(win, ierror)
            IMPORT :: MPI_Win
            TYPE(MPI_Win), INTENT(INOUT) :: win
            INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        END SUBROUTINE

        FUNCTION MPI_Wtime() RESULT(t)
            DOUBLE PRECISION :: t
        END FUNCTION

        FUNCTION MPI_Wtick() RESULT(t)
            DOUBLE PRECISION :: t
        END FUNCTION

    END INTERFACE

    ! ── Comparison operators for derived types ────────────────────────────────
    INTERFACE OPERATOR(==)
        MODULE PROCEDURE mpi_datatype_eq
    END INTERFACE
    INTERFACE OPERATOR(/=)
        MODULE PROCEDURE mpi_datatype_ne
    END INTERFACE

CONTAINS
    PURE LOGICAL FUNCTION mpi_datatype_eq(a, b)
        TYPE(MPI_Datatype), INTENT(IN) :: a, b
        mpi_datatype_eq = (a%MPI_VAL == b%MPI_VAL)
    END FUNCTION
    PURE LOGICAL FUNCTION mpi_datatype_ne(a, b)
        TYPE(MPI_Datatype), INTENT(IN) :: a, b
        mpi_datatype_ne = (a%MPI_VAL /= b%MPI_VAL)
    END FUNCTION

END MODULE mpi_f08
