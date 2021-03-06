require "test_helper"

describe Work do
  let(:work) { works(:one) }
  let(:popular_work) { works(:two) }
  let(:vote_one) { votes(:one) }
  let(:vote_two) { votes(:two) }
  let(:vote_three) { votes(:two) }

  it "must be valid" do
    expect(work.valid?).must_equal true
  end

  describe "validations" do
    it "requires a title" do
      work.title = nil
      valid_work = work.valid?
      expect(valid_work).must_equal false
      expect(work.errors.messages).must_include :title
      expect(work.errors.messages[:title]).must_equal ["can't be blank"]
    end

    it "requires a unique title" do
      dup_work = Work.new(title: work.title)
      expect(dup_work.save).must_equal false
      expect(dup_work.errors.messages).must_include :title
      expect(dup_work.errors.messages[:title]).must_equal ["has already been taken"]
    end
  end

  describe "relationships" do
    it "can have many votes" do
      work.votes << vote_one
      work.votes << vote_two
      expect(work.votes.first).must_equal vote_one
      expect(work.votes.last).must_equal vote_two
    end

    it "can have 0 votes" do
      expect(work.votes.length).must_equal 0
    end
  end

  describe "custom methods" do
    describe "vote_counter" do
      it "returns the correct number of votes" do
        work.votes << vote_one
        work.votes << vote_two
        expect(work.vote_counter).must_equal 2
      end

      it "returns 0 when no votes have been made" do
        expect(work.vote_counter).must_equal 0
      end
    end

    describe "spotlight_work" do
      it "will return the highest voted work" do
        popular_work.votes << vote_one
        popular_work.votes << vote_two
        work.votes << vote_three
        works = [work, popular_work]

        expect(Work.spotlight_work(works)).must_equal popular_work
      end

      it "will return nil if no one has voted yet" do
        works = [work, popular_work]
        expect(Work.spotlight_work(works)).must_equal nil
      end
    end

    describe "top_ten" do
      it "returns an array of ten works sorted by the most count by category - may include 0 votes" do
        works = Work.all
        category_one = works(:one).category
        top_ten_works = Work.top_ten(works, category_one)

        expect(top_ten_works.length).must_equal 10
        expect(top_ten_works).must_include works(:ten)
        expect(top_ten_works).wont_include works(:eleven)
        expect(top_ten_works.first.category).must_equal category_one
      end

      it "returns the max number of works in category is there are less than 10 works" do
        works = Work.all
        category_two = works(:eleven).category
        top_works = Work.top_ten(works, category_two)

        expect(top_works.length).must_equal 1
      end

      it "includes works with zero votes if the there are 10+ works in category but not all have been voted on" do
        works = Work.all
        works.first.votes << vote_one
        works[1].votes << vote_two
        top_works = Work.top_ten(works, works.first.category)
        expect(top_works.length).must_equal works[0..9].length
        expect(top_works).must_include works[9]
        expect(top_works).must_include works[3]
      end
    end
  end
end
