require "test_helper"

describe WorksController do
  it "should get index" do
    get works_path
    must_respond_with :success
  end

  describe "show" do
    it "should be OK to show an existing, valid work" do
      valid_work_id = works(:one).id
      get work_path(valid_work_id)

      must_respond_with :success
    end

    it "should flash instead of showing a non-existant, invalid book" do
      work = works(:one)
      invalid_work_id = work.id
      work.destroy

      get work_path(invalid_work_id)
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Unknown work!"
    end
  end

  describe "create" do
    it "will save a new work and redirect if given valid input" do
      test_input = {
        work: {
          category: "movie",
          title: "test movie",
          creator: "test angela",
          publication_year: 1999,
          description: "test description",
        },
      }

      expect {
        post works_path, params: test_input
      }.must_change "Work.count", 1

      new_work = Work.find_by(title: test_input[:work][:title])
      expect(new_work).wont_be_nil
      expect(new_work.title).must_equal test_input[:work][:title]
      expect(new_work.category).must_equal test_input[:work][:category]
      expect(new_work.creator).must_equal test_input[:work][:creator]
      expect(new_work.publication_year).must_equal test_input[:work][:publication_year]
      expect(new_work.description).must_equal test_input[:work][:description]
      expect(flash[:success]).must_equal "Work added successfully!"
    end

    it "should flash and return a 400 witha an invalid work" do
      test_input = {
        work: {
          category: "movie",
          title: "",
          creator: "test angela",
          publication_year: 1999,
          description: "test description",
        },
      }

      expect {
        post works_path, params: test_input
      }.wont_change "Work.count"
      expect(flash[:title]).must_equal ["can't be blank"]
      must_respond_with :bad_request
    end
  end
end
