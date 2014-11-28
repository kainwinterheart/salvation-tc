use ExtUtils::MakeMaker;
use Devel::PPPort;

Devel::PPPort::WriteFile();

WriteMakefile (
    NAME => 'Salvation::TC::Parser',
    VERSION => '0.01',
    OBJECT => 'helper.o tokenizer.o Parser.o',
);

exit 0;

__END__
