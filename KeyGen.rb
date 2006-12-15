###############################################################################
#
# File: KeyGen.rb
#
# Copyright: Andy Southgate 2006
#
# All rights reserved.  Distribution prohibited.  For information, please
# contact the author via http://www.mushware.com/.
#
# This software carries NO WARRANTY of any kind.
#
###############################################################################

class KeyGenerator
  def initialize
    @m_cppFilename = 'MushSecretKeys.cpp'
    @m_rbFilename = 'MushSecretKeys.rb'
    @m_numKeys = 2
    @m_keysData = {}
    @m_keySize = 65536
  end
  
  def mKeyDataGenerate(inNum)
    @m_keysData[inNum] = []
    @m_keySize.times do
      @m_keysData[inNum] << rand(256)
    end
  end
  
  def mCPPSave
    File.open(@m_cppFilename, 'w') do |file|
      file << <<EOS
/*****************************************************************************
 *
 * File: #{@m_cppFilename}
 *
 * Copyright: Andy Southgate 2006
 *
 * All rights reserved.  Distribution prohibited.  For information, please
 * contact the author via http://www.mushware.com/.
 *
 * This software carries NO WARRANTY of any kind.
 *
 ****************************************************************************/

#include "API/mushMushcore.h"        
#include "API/mushMushFile.h"        
EOS
      @m_keysData.each do |i, data|
        file << <<EOS
        
static Mushware::U8 Key#{i}[#{@m_keySize}] =
{
EOS
        @m_keySize.times do |j|
          file << "    " if (j % 16) == 0
          file << "0x%02X" % data[j]
          file << "," unless j+1 == @m_keySize
          file << "\n" if (j % 16) == 15
        end

        file << <<EOS
};

EOS
      end

      file << <<EOS
namespace
{
    void Installer(void)
    {
EOS
      @m_keysData.each do |i, data|
        file << <<EOS
        MushFileKeys::Sgl().KeyEntryAdd(#{i}, Key#{i});
EOS
      end
    file << <<EOS
    }
    
    MushcoreInstaller Install(Installer);
}
EOS
    end
  end
  
  def mRBSave
    File.open(@m_rbFilename, 'w') do |file|
      file << <<EOS
###############################################################################
#
# File: #{@m_rbFilename}
#
# Copyright: Andy Southgate 2006
#
# All rights reserved.  Distribution prohibited.  For information, please
# contact the author via http://www.mushware.com/.
#
# This software carries NO WARRANTY of any kind.
#
###############################################################################

class MushSecretKeys

  @@c_keys = {
EOS
      @m_keysData.each do |i, data|
        file << <<EOS
    #{i} => [
EOS
        @m_keySize.times do |j|
          file << "      " if (j % 16) == 0
          file << "0x%02X" % data[j]
          file << "," unless j+1 == @m_keySize
          file << "\n" if (j % 16) == 15
        end

        file << <<EOS
    ],
EOS
      end

      file << <<EOS
  }
end
EOS
    end
  end
  
  def mGenerate
    @m_numKeys.times do |i|
      mKeyDataGenerate(i+1)
    end
    mCPPSave
    mRBSave
  end
end

generator = KeyGenerator.new
generator.mGenerate
puts 'Done.'
