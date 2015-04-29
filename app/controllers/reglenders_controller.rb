class ReglendersController < ApplicationController

	def new
		@lender = Lender.new
	end

	def create
		#create new lender here!
	  	@lender = Lender.new(lender_params)
	  	if @lender.save
  			# now that account created.  lets put amount in tranaction  table for reference.
  			session[:id] = lender[:id]
  			session[:name] = lender[:first_name] + " " + lender[:last_name]
  			session[:lendable] = lender[:lendable]

  			redirect_to reglenders_show_path

	  	else

	  		render 'new'
	  	end
	end

	def login

		@lender = Lender.find_by_email(params[:lender][:email]) # load infor this email

		# this section this is for login type of lender!
		# read lender details

		if @lender && params[:lender][:password] == @lender[:password] then
		  # success! Sweet
		  session[:id] = @lender[:id]
		  session[:name] = @lender[:first_name] + " " + @lender[:last_name]
		  session[:lendable] = @lender[:lendable]

		  redirect_to reglenders_show_path

		else
		  @lender = Lender.new
		  @lender.errors.add(:Account," : Unabale to process login.")
		  @borrower = Borrower.new
		  render users_index_path

		end

	end

	def show
		# amount raised calculated from sums of individual loads. loans with same id, same lender and same borrower with show amount
		#  can break down later to make EACH transaction separate for record kepping and indivudual % rates.
		# @lender = Lender.find(session[:id]) # find logged in lender.
		#@borrowers = Borrower.all # need join that joins history with borrowers.
		session[:lendable] = Lender.find(session[:id]).lendable
    	@my_loans = Borrower.select("borrowers.first_name, borrowers.last_name, histories.*").joins(:histories).where("lender_id = ?",session[:id])
    	@open_loans = Borrower.select("borrowers.first_name, borrowers.last_name, histories.*").joins(:histories).where("lender_id = ?",session[:id])
		#@newloan = History.new
		#@open_loans = History.all.joins(:borrowers).select(:id,:first_name, :last_name, :email, :loan, :needed_for, :description, :amount_procured).where('amount_procured < loan')
		#@my_loans = History.all.joins(:borrowers, :lenders).where('lenders.id = '+session[:id].to_s).select('lenders.id, borrowers.first_name, borrowers.last_name, histories.loan, histories.amount_procured, histories.needed_for, histories.description')
	end

	def update
		# want to use patch/put on this, but need to find method settings for this.
		#hold in this first. we are getting amount and id, so we can send the money to the right place.
		@newlend = params(newlend_params) # :id in params from url post.
		@history = History.find(@newlend[:id])
		@history[:amount_procured] =+ @newlend[:loan_amount]

		@history.save
		# regardless go back. can add a success banner if need
		redirect_to reglenders_show_path

	end

private

	def lender_params
		params.require(:lender).permit(:first_name, :last_name, :email, :password, :lendable)
	end

	def newlend_params
	 	params.require(:newloan).permit(:loan_amount)
	end

end