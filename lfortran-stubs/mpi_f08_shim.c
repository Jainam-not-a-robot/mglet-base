/*
 * mpi_f08_shim.c — C side of the LFortran mpi_f08 stub (mpi_f08.f90)
 *
 * The Fortran wrappers in mpi_f08.f90 pass each choice buffer as a BIND(C)
 * assumed-rank argument, so it arrives here as an ISO_Fortran_binding
 * descriptor whose base_addr is the address of the actual argument (an
 * array, an array element, a scalar or a component; never a copy). Handles
 * arrive as Open MPI Fortran handles and are converted with the MPI_*_f2c
 * and MPI_*_c2f functions, so this file does not depend on how Open MPI
 * numbers them.
 *
 * Compile with the mpicc of the Open MPI that mglet links, and with
 * LFortran's ISO_Fortran_binding.h on the include path.
 */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "ISO_Fortran_binding.h"

/* Addresses of MPI_IN_PLACE, MPI_STATUS_IGNORE and MPI_STATUSES_IGNORE in
 * the Fortran module, registered by its MPI_Init wrapper */
static void *f_in_place, *f_status_ignore, *f_statuses_ignore;

void lfmpi_set_sentinels(void *in_place, void *status_ignore,
                         void *statuses_ignore)
{
    f_in_place = in_place;
    f_status_ignore = status_ignore;
    f_statuses_ignore = statuses_ignore;
}

static void *buf(const CFI_cdesc_t *d)
{
    return d->base_addr == f_in_place ? MPI_IN_PLACE : d->base_addr;
}

/* Open MPI routines behind the mpif.h bindings of MPI_Op_create and
 * MPI_Comm_create_errhandler. They mark the callback as a Fortran procedure,
 * so Open MPI calls it with Fortran handles passed by reference. */
void ompi_op_create_f(void *function, MPI_Fint *commute, MPI_Fint *op,
                      MPI_Fint *ierr);
void ompi_comm_create_errhandler_f(void *function, MPI_Fint *errhandler,
                                   MPI_Fint *ierr);

/* Abort if a handle or constant in mpi_f08.f90 differs from this Open MPI */
static int check(const char *name, MPI_Fint f, MPI_Fint expected)
{
    if (f == expected) return 0;
    fprintf(stderr, "mpi_f08 stub: %s is %d in mpi_f08.f90 but %d in this "
            "Open MPI; update lfortran-stubs/mpi_f08.f90\n", name, (int)f,
            (int)expected);
    return 1;
}

int lfmpi_check_constants(const MPI_Fint *f)
{
    int bad = 0;
    bad += check("MPI_COMM_WORLD", f[0], MPI_Comm_c2f(MPI_COMM_WORLD));
    bad += check("MPI_COMM_NULL", f[1], MPI_Comm_c2f(MPI_COMM_NULL));
    bad += check("MPI_WIN_NULL", f[2], MPI_Win_c2f(MPI_WIN_NULL));
    bad += check("MPI_BYTE", f[3], MPI_Type_c2f(MPI_BYTE));
    bad += check("MPI_REAL", f[4], MPI_Type_c2f(MPI_REAL));
    bad += check("MPI_DOUBLE_PRECISION", f[5],
                 MPI_Type_c2f(MPI_DOUBLE_PRECISION));
    bad += check("MPI_INTEGER", f[6], MPI_Type_c2f(MPI_INTEGER));
    bad += check("MPI_INTEGER8", f[7], MPI_Type_c2f(MPI_INTEGER8));
    bad += check("MPI_LOGICAL", f[8], MPI_Type_c2f(MPI_LOGICAL));
    bad += check("MPI_CHARACTER", f[9], MPI_Type_c2f(MPI_CHARACTER));
    bad += check("MPI_REAL8", f[10], MPI_Type_c2f(MPI_REAL8));
    bad += check("MPI_AINT", f[11], MPI_Type_c2f(MPI_AINT));
    bad += check("MPI_SUM", f[12], MPI_Op_c2f(MPI_SUM));
    bad += check("MPI_MAX", f[13], MPI_Op_c2f(MPI_MAX));
    bad += check("MPI_MIN", f[14], MPI_Op_c2f(MPI_MIN));
    bad += check("MPI_REQUEST_NULL", f[15], MPI_Request_c2f(MPI_REQUEST_NULL));
    bad += check("MPI_INFO_NULL", f[16], MPI_Info_c2f(MPI_INFO_NULL));
    bad += check("MPI_UNDEFINED", f[17], MPI_UNDEFINED);
    bad += check("MPI_PROC_NULL", f[18], MPI_PROC_NULL);
    bad += check("MPI_COMM_TYPE_SHARED", f[19], MPI_COMM_TYPE_SHARED);
    bad += check("MPI_STATUS_SIZE", f[20], MPI_F_STATUS_SIZE);
    bad += check("MPI_MAX_ERROR_STRING", f[21], MPI_MAX_ERROR_STRING - 1);
    bad += check("MPI_MAX_LIBRARY_VERSION_STRING", f[22],
                 MPI_MAX_LIBRARY_VERSION_STRING - 1);
    bad += check("MPI_ADDRESS_KIND", f[23], (MPI_Fint)sizeof(MPI_Aint));
    if (bad) MPI_Abort(MPI_COMM_WORLD, 1);
    return MPI_SUCCESS;
}

/* A Fortran MPI_Status is MPI_STATUS_SIZE default integers */
static MPI_Status *status_in(MPI_Fint *f, MPI_Status *c)
{
    return (void *)f == f_status_ignore ? MPI_STATUS_IGNORE : c;
}

static void status_out(const MPI_Status *c, MPI_Fint *f)
{
    if ((void *)f != f_status_ignore) MPI_Status_c2f(c, f);
}

/* ── Environment ─────────────────────────────────────────────────────────── */

int lfmpi_init(void) { return MPI_Init(NULL, NULL); }
int lfmpi_finalize(void) { return MPI_Finalize(); }
double lfmpi_wtime(void) { return MPI_Wtime(); }
double lfmpi_wtick(void) { return MPI_Wtick(); }

int lfmpi_abort(MPI_Fint comm, MPI_Fint errorcode)
{
    return MPI_Abort(MPI_Comm_f2c(comm), errorcode);
}

int lfmpi_error_class(MPI_Fint errorcode, MPI_Fint *errorclass)
{
    int c;
    int ierr = MPI_Error_class(errorcode, &c);
    *errorclass = c;
    return ierr;
}

/* `string` has room for MPI_MAX_ERROR_STRING characters */
int lfmpi_error_string(MPI_Fint errorcode, char *string, MPI_Fint *resultlen)
{
    int len;
    int ierr = MPI_Error_string(errorcode, string, &len);
    *resultlen = len;
    return ierr;
}

/* `version` has room for MPI_MAX_LIBRARY_VERSION_STRING characters */
int lfmpi_get_library_version(char *version, MPI_Fint *resultlen)
{
    int len;
    int ierr = MPI_Get_library_version(version, &len);
    *resultlen = len;
    return ierr;
}

/* ── Communicators and error handlers ───────────────────────────────────── */

int lfmpi_comm_rank(MPI_Fint comm, MPI_Fint *rank)
{
    int r;
    int ierr = MPI_Comm_rank(MPI_Comm_f2c(comm), &r);
    *rank = r;
    return ierr;
}

int lfmpi_comm_size(MPI_Fint comm, MPI_Fint *size)
{
    int s;
    int ierr = MPI_Comm_size(MPI_Comm_f2c(comm), &s);
    *size = s;
    return ierr;
}

int lfmpi_comm_dup(MPI_Fint comm, MPI_Fint *newcomm)
{
    MPI_Comm c;
    int ierr = MPI_Comm_dup(MPI_Comm_f2c(comm), &c);
    *newcomm = MPI_Comm_c2f(c);
    return ierr;
}

int lfmpi_comm_free(MPI_Fint *comm)
{
    MPI_Comm c = MPI_Comm_f2c(*comm);
    int ierr = MPI_Comm_free(&c);
    *comm = MPI_Comm_c2f(c);
    return ierr;
}

int lfmpi_comm_split(MPI_Fint comm, MPI_Fint color, MPI_Fint key,
                     MPI_Fint *newcomm)
{
    MPI_Comm c;
    int ierr = MPI_Comm_split(MPI_Comm_f2c(comm), color, key, &c);
    *newcomm = MPI_Comm_c2f(c);
    return ierr;
}

int lfmpi_comm_split_type(MPI_Fint comm, MPI_Fint split_type, MPI_Fint key,
                          MPI_Fint info, MPI_Fint *newcomm)
{
    MPI_Comm c;
    int ierr = MPI_Comm_split_type(MPI_Comm_f2c(comm), split_type, key,
                                   MPI_Info_f2c(info), &c);
    *newcomm = MPI_Comm_c2f(c);
    return ierr;
}

int lfmpi_comm_create_errhandler(void *function, MPI_Fint *errhandler)
{
    MPI_Fint ierr;
    ompi_comm_create_errhandler_f(function, errhandler, &ierr);
    return ierr;
}

int lfmpi_comm_set_errhandler(MPI_Fint comm, MPI_Fint errhandler)
{
    return MPI_Comm_set_errhandler(MPI_Comm_f2c(comm),
                                   MPI_Errhandler_f2c(errhandler));
}

int lfmpi_errhandler_free(MPI_Fint *errhandler)
{
    MPI_Errhandler e = MPI_Errhandler_f2c(*errhandler);
    int ierr = MPI_Errhandler_free(&e);
    *errhandler = MPI_Errhandler_c2f(e);
    return ierr;
}

/* ── Point to point ──────────────────────────────────────────────────────── */

int lfmpi_send(const CFI_cdesc_t *b, MPI_Fint count, MPI_Fint datatype,
               MPI_Fint dest, MPI_Fint tag, MPI_Fint comm)
{
    return MPI_Send(b->base_addr, count, MPI_Type_f2c(datatype), dest, tag,
                    MPI_Comm_f2c(comm));
}

int lfmpi_recv(const CFI_cdesc_t *b, MPI_Fint count, MPI_Fint datatype,
               MPI_Fint source, MPI_Fint tag, MPI_Fint comm, MPI_Fint *status)
{
    MPI_Status c;
    int ierr = MPI_Recv(b->base_addr, count, MPI_Type_f2c(datatype), source,
                        tag, MPI_Comm_f2c(comm), status_in(status, &c));
    status_out(&c, status);
    return ierr;
}

int lfmpi_isend(const CFI_cdesc_t *b, MPI_Fint count, MPI_Fint datatype,
                MPI_Fint dest, MPI_Fint tag, MPI_Fint comm, MPI_Fint *request)
{
    MPI_Request r;
    int ierr = MPI_Isend(b->base_addr, count, MPI_Type_f2c(datatype), dest,
                         tag, MPI_Comm_f2c(comm), &r);
    *request = MPI_Request_c2f(r);
    return ierr;
}

int lfmpi_irecv(const CFI_cdesc_t *b, MPI_Fint count, MPI_Fint datatype,
                MPI_Fint source, MPI_Fint tag, MPI_Fint comm,
                MPI_Fint *request)
{
    MPI_Request r;
    int ierr = MPI_Irecv(b->base_addr, count, MPI_Type_f2c(datatype), source,
                         tag, MPI_Comm_f2c(comm), &r);
    *request = MPI_Request_c2f(r);
    return ierr;
}

int lfmpi_wait(MPI_Fint *request, MPI_Fint *status)
{
    MPI_Request r = MPI_Request_f2c(*request);
    MPI_Status c;
    int ierr = MPI_Wait(&r, status_in(status, &c));
    *request = MPI_Request_c2f(r);
    status_out(&c, status);
    return ierr;
}

int lfmpi_waitall(MPI_Fint count, MPI_Fint *requests, MPI_Fint *statuses)
{
    int ignore = (void *)statuses == f_statuses_ignore;
    MPI_Request *r = malloc((count > 0 ? count : 1) * sizeof(MPI_Request));
    MPI_Status *c = ignore ? MPI_STATUSES_IGNORE
                           : malloc((count > 0 ? count : 1) * sizeof(MPI_Status));
    for (int i = 0; i < count; i++) r[i] = MPI_Request_f2c(requests[i]);
    int ierr = MPI_Waitall(count, r, c);
    for (int i = 0; i < count; i++) {
        requests[i] = MPI_Request_c2f(r[i]);
        if (!ignore) MPI_Status_c2f(&c[i], statuses + i * MPI_F_STATUS_SIZE);
    }
    if (!ignore) free(c);
    free(r);
    return ierr;
}

/* `index` is 1-based, or MPI_UNDEFINED */
int lfmpi_waitany(MPI_Fint count, MPI_Fint *requests, MPI_Fint *index,
                  MPI_Fint *status)
{
    MPI_Request *r = malloc((count > 0 ? count : 1) * sizeof(MPI_Request));
    MPI_Status c;
    int i;
    for (i = 0; i < count; i++) r[i] = MPI_Request_f2c(requests[i]);
    int ierr = MPI_Waitany(count, r, &i, status_in(status, &c));
    if (i == MPI_UNDEFINED) {
        *index = MPI_UNDEFINED;
    } else {
        requests[i] = MPI_Request_c2f(r[i]);
        *index = i + 1;
    }
    status_out(&c, status);
    free(r);
    return ierr;
}

int lfmpi_get_count(MPI_Fint *status, MPI_Fint datatype, MPI_Fint *count)
{
    MPI_Status c;
    int n;
    MPI_Status_f2c(status, &c);
    int ierr = MPI_Get_count(&c, MPI_Type_f2c(datatype), &n);
    *count = n;
    return ierr;
}

/* ── Collectives ─────────────────────────────────────────────────────────── */

int lfmpi_barrier(MPI_Fint comm)
{
    return MPI_Barrier(MPI_Comm_f2c(comm));
}

int lfmpi_bcast(const CFI_cdesc_t *b, MPI_Fint count, MPI_Fint datatype,
                MPI_Fint root, MPI_Fint comm)
{
    return MPI_Bcast(b->base_addr, count, MPI_Type_f2c(datatype), root,
                     MPI_Comm_f2c(comm));
}

int lfmpi_reduce(const CFI_cdesc_t *s, const CFI_cdesc_t *r, MPI_Fint count,
                 MPI_Fint datatype, MPI_Fint op, MPI_Fint root, MPI_Fint comm)
{
    return MPI_Reduce(buf(s), r->base_addr, count, MPI_Type_f2c(datatype),
                      MPI_Op_f2c(op), root, MPI_Comm_f2c(comm));
}

int lfmpi_allreduce(const CFI_cdesc_t *s, const CFI_cdesc_t *r,
                    MPI_Fint count, MPI_Fint datatype, MPI_Fint op,
                    MPI_Fint comm)
{
    return MPI_Allreduce(buf(s), r->base_addr, count, MPI_Type_f2c(datatype),
                         MPI_Op_f2c(op), MPI_Comm_f2c(comm));
}

int lfmpi_gather(const CFI_cdesc_t *s, MPI_Fint sendcount, MPI_Fint sendtype,
                 const CFI_cdesc_t *r, MPI_Fint recvcount, MPI_Fint recvtype,
                 MPI_Fint root, MPI_Fint comm)
{
    return MPI_Gather(buf(s), sendcount, MPI_Type_f2c(sendtype), r->base_addr,
                      recvcount, MPI_Type_f2c(recvtype), root,
                      MPI_Comm_f2c(comm));
}

int lfmpi_gatherv(const CFI_cdesc_t *s, MPI_Fint sendcount, MPI_Fint sendtype,
                  const CFI_cdesc_t *r, const MPI_Fint *recvcounts,
                  const MPI_Fint *displs, MPI_Fint recvtype, MPI_Fint root,
                  MPI_Fint comm)
{
    return MPI_Gatherv(buf(s), sendcount, MPI_Type_f2c(sendtype),
                       r->base_addr, recvcounts, displs,
                       MPI_Type_f2c(recvtype), root, MPI_Comm_f2c(comm));
}

int lfmpi_scatterv(const CFI_cdesc_t *s, const MPI_Fint *sendcounts,
                   const MPI_Fint *displs, MPI_Fint sendtype,
                   const CFI_cdesc_t *r, MPI_Fint recvcount, MPI_Fint recvtype,
                   MPI_Fint root, MPI_Fint comm)
{
    return MPI_Scatterv(s->base_addr, sendcounts, displs,
                        MPI_Type_f2c(sendtype), buf(r), recvcount,
                        MPI_Type_f2c(recvtype), root, MPI_Comm_f2c(comm));
}

int lfmpi_allgather(const CFI_cdesc_t *s, MPI_Fint sendcount,
                    MPI_Fint sendtype, const CFI_cdesc_t *r,
                    MPI_Fint recvcount, MPI_Fint recvtype, MPI_Fint comm)
{
    return MPI_Allgather(buf(s), sendcount, MPI_Type_f2c(sendtype),
                         r->base_addr, recvcount, MPI_Type_f2c(recvtype),
                         MPI_Comm_f2c(comm));
}

int lfmpi_allgatherv(const CFI_cdesc_t *s, MPI_Fint sendcount,
                     MPI_Fint sendtype, const CFI_cdesc_t *r,
                     const MPI_Fint *recvcounts, const MPI_Fint *displs,
                     MPI_Fint recvtype, MPI_Fint comm)
{
    return MPI_Allgatherv(buf(s), sendcount, MPI_Type_f2c(sendtype),
                          r->base_addr, recvcounts, displs,
                          MPI_Type_f2c(recvtype), MPI_Comm_f2c(comm));
}

int lfmpi_alltoall(const CFI_cdesc_t *s, MPI_Fint sendcount,
                   MPI_Fint sendtype, const CFI_cdesc_t *r,
                   MPI_Fint recvcount, MPI_Fint recvtype, MPI_Fint comm)
{
    return MPI_Alltoall(buf(s), sendcount, MPI_Type_f2c(sendtype),
                        r->base_addr, recvcount, MPI_Type_f2c(recvtype),
                        MPI_Comm_f2c(comm));
}

int lfmpi_alltoallv(const CFI_cdesc_t *s, const MPI_Fint *sendcounts,
                    const MPI_Fint *sdispls, MPI_Fint sendtype,
                    const CFI_cdesc_t *r, const MPI_Fint *recvcounts,
                    const MPI_Fint *rdispls, MPI_Fint recvtype, MPI_Fint comm)
{
    return MPI_Alltoallv(buf(s), sendcounts, sdispls, MPI_Type_f2c(sendtype),
                         r->base_addr, recvcounts, rdispls,
                         MPI_Type_f2c(recvtype), MPI_Comm_f2c(comm));
}

/* ── Datatypes and operations ───────────────────────────────────────────── */

int lfmpi_get_address(const CFI_cdesc_t *location, MPI_Aint *address)
{
    return MPI_Get_address(location->base_addr, address);
}

int lfmpi_type_contiguous(MPI_Fint count, MPI_Fint oldtype, MPI_Fint *newtype)
{
    MPI_Datatype t;
    int ierr = MPI_Type_contiguous(count, MPI_Type_f2c(oldtype), &t);
    *newtype = MPI_Type_c2f(t);
    return ierr;
}

int lfmpi_type_indexed(MPI_Fint count, const MPI_Fint *blocklengths,
                       const MPI_Fint *displacements, MPI_Fint oldtype,
                       MPI_Fint *newtype)
{
    MPI_Datatype t;
    int ierr = MPI_Type_indexed(count, blocklengths, displacements,
                                MPI_Type_f2c(oldtype), &t);
    *newtype = MPI_Type_c2f(t);
    return ierr;
}

int lfmpi_type_create_struct(MPI_Fint count, const MPI_Fint *blocklengths,
                             const MPI_Aint *displacements,
                             const MPI_Fint *types, MPI_Fint *newtype)
{
    MPI_Datatype *c = malloc((count > 0 ? count : 1) * sizeof(MPI_Datatype));
    MPI_Datatype t;
    for (int i = 0; i < count; i++) c[i] = MPI_Type_f2c(types[i]);
    int ierr = MPI_Type_create_struct(count, blocklengths, displacements, c,
                                      &t);
    *newtype = MPI_Type_c2f(t);
    free(c);
    return ierr;
}

int lfmpi_type_commit(MPI_Fint *datatype)
{
    MPI_Datatype t = MPI_Type_f2c(*datatype);
    int ierr = MPI_Type_commit(&t);
    *datatype = MPI_Type_c2f(t);
    return ierr;
}

int lfmpi_type_free(MPI_Fint *datatype)
{
    MPI_Datatype t = MPI_Type_f2c(*datatype);
    int ierr = MPI_Type_free(&t);
    *datatype = MPI_Type_c2f(t);
    return ierr;
}

int lfmpi_type_get_extent(MPI_Fint datatype, MPI_Aint *lb, MPI_Aint *extent)
{
    return MPI_Type_get_extent(MPI_Type_f2c(datatype), lb, extent);
}

int lfmpi_type_create_resized(MPI_Fint oldtype, MPI_Aint lb, MPI_Aint extent,
                              MPI_Fint *newtype)
{
    MPI_Datatype t;
    int ierr = MPI_Type_create_resized(MPI_Type_f2c(oldtype), lb, extent, &t);
    *newtype = MPI_Type_c2f(t);
    return ierr;
}

int lfmpi_op_create(void *function, MPI_Fint commute, MPI_Fint *op)
{
    MPI_Fint ierr;
    ompi_op_create_f(function, &commute, op, &ierr);
    return ierr;
}

int lfmpi_op_free(MPI_Fint *op)
{
    MPI_Op o = MPI_Op_f2c(*op);
    int ierr = MPI_Op_free(&o);
    *op = MPI_Op_c2f(o);
    return ierr;
}

/* ── Shared memory windows ──────────────────────────────────────────────── */

int lfmpi_win_allocate_shared(MPI_Aint size, MPI_Fint disp_unit, MPI_Fint info,
                              MPI_Fint comm, void **baseptr, MPI_Fint *win)
{
    MPI_Win w;
    int ierr = MPI_Win_allocate_shared(size, disp_unit, MPI_Info_f2c(info),
                                       MPI_Comm_f2c(comm), baseptr, &w);
    *win = MPI_Win_c2f(w);
    return ierr;
}

int lfmpi_win_shared_query(MPI_Fint win, MPI_Fint rank, MPI_Aint *size,
                           MPI_Fint *disp_unit, void **baseptr)
{
    int d;
    int ierr = MPI_Win_shared_query(MPI_Win_f2c(win), rank, size, &d, baseptr);
    *disp_unit = d;
    return ierr;
}

int lfmpi_win_fence(MPI_Fint assert, MPI_Fint win)
{
    return MPI_Win_fence(assert, MPI_Win_f2c(win));
}

int lfmpi_win_free(MPI_Fint *win)
{
    MPI_Win w = MPI_Win_f2c(*win);
    int ierr = MPI_Win_free(&w);
    *win = MPI_Win_c2f(w);
    return ierr;
}
