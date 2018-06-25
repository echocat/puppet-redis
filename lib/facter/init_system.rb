Facter.add(:init_system) do
  setcode do
    Facter::Util::Resolution.exec('readlink /proc/1/exe')
  end
end
