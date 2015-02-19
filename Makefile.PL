use ExtUtils::MakeMaker;
use Devel::PPPort;

Devel::PPPort::WriteFile();

WriteMakefile (
    NAME => 'Salvation::TC',
    VERSION => '0.01',
    OBJECT => 'helper.o tokenizer.o TC.o',
    CCFLAGS => '-std=c99',
);

exit 0;

__END__
