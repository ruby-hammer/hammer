describe Hammer::Component::State do
  State = Hammer::Component::State

  let :states do
    [[true, true], [true, false], [false, false], [false, true]].map do |a, b|
      State.new.instance_eval { @changed = a; @sent = b; self }
    end
  end

  describe 'when change!' do
    4.times do |i|
      describe "state #{i}" do
        before { states.each &:change! }
        it { states[i].should be_changed }
        it { states[i].should_not be_sent }
      end
    end
  end

  describe 'when unchange!' do
    4.times do |i|
      describe "state #{i}" do
        before { states.each &:unchange! }
        it { states[i].should_not be_changed }
      end
    end
  end

  describe 'when send!' do
    4.times do |i|
      describe "state #{i}" do
        before { states.each &:send! }
        it { states[i].should be_sent }
      end
    end
  end

  describe 'when new!' do
    4.times do |i|
      describe "state #{i}" do
        before { states.each &:new! }
        it { states[i].should_not be_sent }
      end
    end
  end

end
