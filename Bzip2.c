/*
 * This file was generated automatically by xsubpp version 1.9507 from the 
 * contents of Bzip2.xs. Do not edit this file, edit Bzip2.xs instead.
 *
 *	ANY CHANGES MADE HERE WILL BE LOST! 
 *
 */

#line 1 "Bzip2.xs"
/* BZip2.xs -- Bzip2 bindings for Perl5
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <bzlib.h>

#define UNUSED(x)       x = x

static SV *deRef(SV *sv, char *method)
{
	SV *last_sv = NULL;
	while (SvROK(sv) && sv != last_sv)
	{
		last_sv = sv;
		sv = SvRV(sv);
	}
	if (!SvOK(sv))
	 croak("Compress::Bzip2::%s: buffer parameter is not SCALAR", method);
	return sv ;
}

static double constant(char *name, int arg)
{
    UNUSED(name);
    UNUSED(arg);
	errno = EINVAL;
	return 0;
}


/***********************************************************************
// XSUB start
************************************************************************/

#line 48 "Bzip2.c"
XS(XS_Compress__Bzip2_constant)
{
    dXSARGS;
    if (items != 2)
	Perl_croak(aTHX_ "Usage: Compress::Bzip2::constant(name, arg)");
    {
	char *	name = (char *)SvPV(ST(0),PL_na);
	int	arg = (int)SvIV(ST(1));
	double	RETVAL;
	dXSTARG;

	RETVAL = constant(name, arg);
	XSprePUSH; PUSHn((double)RETVAL);
    }
    XSRETURN(1);
}

XS(XS_Compress__Bzip2_compress)
{
    dXSARGS;
    if (items < 1 || items > 2)
	Perl_croak(aTHX_ "Usage: Compress::Bzip2::compress(string, level = 1)");
    {
#line 55 "Bzip2.xs"
		SV *		sv;
		STRLEN		len;
		int		level = 1;
		unsigned char *	in;
		unsigned char *	out;
		void *		wrkmem;
		unsigned int	in_len;
		unsigned int	out_len;
		unsigned int	new_len;
		int		err;
#line 83 "Bzip2.c"
	SV *	RETVAL;
#line 66 "Bzip2.xs"
		sv = deRef(ST(0), "compress");
		in = (unsigned char *) SvPV(sv, len);
		if (items == 2 && SvOK(ST(1)))
			level = SvIV(ST(1));
		in_len = len;
		out_len = in_len * 1.01 + 600;
		RETVAL = newSV(out_len);
		SvPOK_only(RETVAL);

		out = SvPVX(RETVAL);
		new_len = out_len;

		out[0] = 0xf0;
                err = BZ2_bzBuffToBuffCompress(out,&new_len,in,in_len,6,0,240);

		if (err != BZ_OK || new_len > out_len)
		{
			SvREFCNT_dec(RETVAL);
			XSRETURN_UNDEF;
		}
		SvCUR_set(RETVAL,new_len);

#line 108 "Bzip2.c"
	ST(0) = RETVAL;
	sv_2mortal(ST(0));
    }
    XSRETURN(1);
}

XS(XS_Compress__Bzip2_decompress)
{
    dXSARGS;
    if (items < 1 || items > 2)
	Perl_croak(aTHX_ "Usage: Compress::Bzip2::decompress(string, ratio = 20)");
    {
#line 100 "Bzip2.xs"
		SV *		sv;
		STRLEN		len;
		unsigned int	ratio = 20;
		unsigned char *	in;
		unsigned char *	out;
		unsigned int	in_len;
		unsigned int	out_len;
		unsigned int	new_len;
		int		err;
#line 131 "Bzip2.c"
	SV *	RETVAL;
#line 111 "Bzip2.xs"
      if (items == 2 && SvOK(ST(1)))
         ratio = SvIV(ST(1));

		// sv is a pointer to a string, - it'd be nice to know what dvRef does??
		sv = deRef(ST(0), "decompress");

		// SvPV returns a pointer to the string in the SV
		// so in is a pointer, to what the heck is is len??
		// well len is defined above as STRLEN so it must the length of the sv (funny - I wonder why
		// SvPV can't figure it out then len on it's own??)
		in 	= (unsigned char *) SvPV(sv, len);


		in_len = len;
		out_len = in_len*ratio;

		RETVAL = newSV(out_len > 0 ? out_len : 1);
		SvPOK_only(RETVAL);
		out = SvPVX(RETVAL);

		new_len = out_len;

		err = BZ2_bzBuffToBuffDecompress(out,&new_len,in,in_len,0,0);
		if (err != BZ_OK || new_len == out_len)
		{
			SvREFCNT_dec(RETVAL);
			XSRETURN_UNDEF;
		}

		SvCUR_set(RETVAL, new_len);
#line 164 "Bzip2.c"
	ST(0) = RETVAL;
	sv_2mortal(ST(0));
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS(boot_Compress__Bzip2)
{
    dXSARGS;
    char* file = __FILE__;

    XS_VERSION_BOOTCHECK ;

        newXSproto("Compress::Bzip2::constant", XS_Compress__Bzip2_constant, file, "$$");
        newXSproto("Compress::Bzip2::compress", XS_Compress__Bzip2_compress, file, "$;$");
        newXSproto("Compress::Bzip2::decompress", XS_Compress__Bzip2_decompress, file, "$;$");

    /* Initialisation Section */

#line 44 "Bzip2.xs"
	if (BZ2_bzlibVersion() == NULL)
		croak("Compress::Bzip2 cannot load bzip-libraray %s\n",BZ2_bzlibVersion()) ;

#line 191 "Bzip2.c"

    /* End of Initialisation Section */

    XSRETURN_YES;
}

