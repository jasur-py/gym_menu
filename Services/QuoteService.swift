//
//  QuoteService.swift
//  GymPin
//
//  Manages daily motivational quotes
//

import Foundation
import Combine

class QuoteService: ObservableObject {
    static let shared = QuoteService()
    
    @Published var shouldShowQuote: Bool = false
    @Published var currentQuote: String = ""
    
    private let lastQuoteDateKey = "lastQuoteDate"
    private let dismissedQuotesKey = "dismissedQuotes"
    
    private var allQuotes: [String] = []
    
    private init() {
        loadQuotes()
        checkIfShouldShowQuote()
    }
    
    // Load quotes from embedded text
    private func loadQuotes() {
        // Embedded quotes from motivational_quotes.txt
        let quotesText = """
To accomplish great things, we must not only act, but also dream, not only plan, but also believe.
- Anatole France

When you think you can't... revisit a previous triumph.
- Jack Canfield

Sometimes things become possible if we want them bad enough.
- T.S. Eliot

To be a leader, you must stand for something, or you will fall for anything.
- Anthony Pagano

Don't you get it? This very second you could be doing something you love and dream about doing. So do it! NOW!

Courage is facing your fears. Stupidity is fearing nothing.
- Todd Bellemare

The spirit, the will to win, and the will to excel are the things that endure. These qualities are so much more important than the events that occur.
- Vince Lombardi

Victory is always possible for the person who refuses to stop fighting.
- Napoleon Hill

Great works are performed not by strength, but perseverance.
- Dr. Samuel Johnson

People become successful the minute they decide to.
- Harvey Mackay

Good things come to those who hustle while they wait.

The fastest way to pass your own expectations is to add passion to your labor.
- Mike Litman

Success is predictable.
- Brian Tracy

To be a champion, you have to believe in yourself when nobody else will.
- Sugar Ray Robinson

Accept the past for what it was. Acknowledge the present for what it is. Anticipate the future for what it can become.
- Tracy L. McNair

I have tried 99 times and have failed, but on the 100th time came success.
- Albert Einstein

Our mind is the most valuable possession that we have. The quality of our lives is, and will be, a reflection of how well we develop, train, and utilize this precious gift.
- Brian Tracy

Success is more attitude than aptitude.
- Charles R. Swindoll

People with goals succeed because they know where they are going.
- Earl Nightingale

For I can do ALL things through Christ who gives me strength.
- Philippians 4:13

Excellence is not being the best; it is doing your best.

When everything feels like an uphill struggle, just think of the view from the top.

The size of your success depends on the depth of your desire.

Don't limit your challenges; challenge your limits.

Each day we must strive for constant and never ending improvement.
- Anthony Robbins

If you have a burning desire and a plan to take action, there is absolutely nothing you cannot achieve.
- Thomas J. Vilord

Life is only what we choose to make it.

Happiness is the highest level of success.

Anyone who has never made a mistake has never tried anything new.
- Albert Einstein

Without ambition no conquests are made, and no business created. Ambition is the root of all achievement.
- James Champy

80% of success is showing up.
- Woody Allen

He who dares, wins.
- Winston Churchill

Trust in yourself. Your perceptions are often far more accurate than you are willing to believe.
- Claudia Black

We can do anything we want to if we stick to it long enough.
- Helen Keller

Motivation is like food for the brain. You cannot get enough in one sitting. It needs continual and regular refills.
- Peter Davies

Only those who risk going too far can possibly find out how far one can go.
- T.S. Eliot

The achievement of one goal should be the starting point of another.
- Alexander Graham Bell

Concentrated thoughts produce desired results.
- Zig Ziglar

Money never starts an idea; it's the idea that starts the money.
- Mark Victor Hansen

Life is short. Focus from this day forward on making a difference.

I am not just here to make a living; I am here to make a life.
- Helice Bridges

Ideas are a dime a dozen, they are worthless, but people who put their ideas into action are priceless.

You may be disappointed if you fail, but you are doomed if you do not try.
- Beverly Sills

It's not whether you get knocked down; it's whether you get back up.
- Vince Lombardi

Success is neither magical nor mysterious. Success is the natural consequence of consistently applying the basic fundamentals.
- Jim Rohn

I know the price of success: dedication, hard work, and an unremitting devotion to the things you want to see happen.
- Frank Lloyd Wright

The path to success is to take massive determined action.
- Anthony Robbins

Never stop learning. If you learn one new thing everyday, you will overcome 99% of your competition.
- Joe Carlozo

Winning doesn't make you a better person, but being a better person will make you a winner.

The starting point of all achievement is desire. Keep this constantly in mind. Weak desire brings weak results, just as a small amount of fire makes a small amount of heat.
- Napoleon Hill

I do believe I am special. My special gift is my vision, my commitment, and my willingness to do whatever it takes.
- Anthony Robbins

Never give up! Failure and rejection are only the first step to succeeding.
- Jimmy Valvano

Believe in yourself and you will be unstoppable.
- Emily Guay

Failure is merely part of the process necessary for success.

Don't wish for it... work for it!

He who conquers others is strong. He who conquers himself is mighty.
- Lao Tzu

The best way to accomplish something is to just do it, and then find the courage afterwards.

JUST DO IT!
- Nike

Never let your fears be the boundaries of your dreams.

Think BIG! You are going to be thinking anyway, so think BIG!
- Donald Trump

Life's battles don't always go to the faster, stronger man. The man who wins is the man who thinks he can.

Success in the end erases all the mistakes along the way.
- Chinese Proverb

People become really quite remarkable when they start thinking that they can do things. When they believe in themselves, they have the first secret of success.
- Norman Vincent Peale

The day I stop giving is the day I stop receiving. The day I stop learning is the day I stop growing.

Winners are ordinary people with extraordinary heart.

The happiest of people do not necessarily have the best of everything. They just make the most of everything that comes along their way.

True success in life is not measured by how much you make, but by how much of a difference you make.

The secret of success is consistency of purpose.
- Benjamin Disraeli

If the mind of man can believe, the mind of man can achieve.
- Napoleon Hill

To conquer without risk is to triumph without glory.
- El Cid

You miss 100% of the shots you don't take.
- Wayne Gretzky

No man ever became great without many and great mistakes.
- William E. Gladstone

Real success is finding your life work in the work that you love.
- David McCullough

I do not think there is any other quality so essential to success of any kind as the quality of perseverance. It overcomes almost everything, even nature.
- John D. Rockefeller

Creativity means believing you have greatness.
- Dr. Wayne D. Dwyer

I can't believe that God put us on this earth just to be ordinary.
- Lou Holtz

Believe that you have it, and you will have it.
- Latin Proverb

In the long run, we only hit what we aim at.
- Henry David Thoreau

There is no shortcut. Victory lies in overcoming obstacles everyday.

Our aspirations are our possibilities.
- Samuel Johnson

Discovery lies in seeing what everyone sees, but thinking what no one has thought.

Life is built of the things we do. The only constructive material is positive action.

Be courageous! Have faith! Go forward.
- Thomas A. Edison

Success seems to be connected with action. Successful men keep moving; they make mistakes, but they do not quit.
- Conrad Hilton

Do not settle for less than an extraordinary life.

Always keep a window open in your mind for new ideas.

I maintained my edge by always being a student; you will always have something new to learn.
- Jackie Joyner Kersee

Keys to success: Research your ideas, plan for success, expect success, and just do it.
- John S. Hinds

You've got to get up every morning with determination if you're going to go to bed with satisfaction.
- George Horace Lorimer

Destiny is not a matter of chance; it's a matter of choice. It is not a thing to be waited for; it is a thing to be achieved.
- Jeremy Kitson

I am a great believer in luck, and I find that the harder I work the more luck I have.
- Thomas Jefferson

Every success is built on the ability to do better than good enough.

Why? Why not? Why not you? Why not now?
- Aslan

Nothing great was ever achieved without enthusiasm.
- Ralph Waldo Emerson

Out of difficulties grow miracles.
- Jean De La Bruyere

What lies behind us and what lies before us are tiny matters compared to what lies within us.
- Ralph Waldo Emerson

We must all suffer one of two things: The pain of discipline or the pain of regret and disappointment.
- Jim Rohn

The greatest glory in living lies not in never falling, but in rising every time we fall.
- Nelson Mandela

All of our dreams can come true if we have the courage to pursue them.
- Walt Disney

To succeed, you need to take that gut feeling in what you believe and act on it with all of your heart.
- Christy Borgeld

Reach for the moon. If you fall short at least you'll be among the stars.

It's in your moments of decision that your destiny is shaped.
- Anthony Robbins

Focus on where you want to go, not where you currently are.

There are no limitations to any of our dreams.
- Gene Simmons

Believe... and the magic will follow.

To be successful you must decide exactly what you want to accomplish, and then resolve to pay the price to get it.
- Bunker Hunt

Success is not where you are in life, but the obstacles you have overcome.
- Booker T. Washington

Action may not bring happiness, but there is no happiness without action.
- William James

Our intentions create our reality.
- Dr. Wayne W. Dyer

We cannot always control what goes on outside, but we can control what goes on inside.

If you realized how powerful your thoughts are, you would never think another negative thought.
- Peace Pilgrim

Experience tells you what to do. Confidence allows you to do it.
- Stan Smith

Everything you want is on the other side of fear.
- Jack Canfield

If you consistently and persistently do the things that other successful people do, nothing in the world can stop you from being a big success also.
- Brian Tracy

Your ability will grow to match your dreams.
- Jim Rohn

Ask yourself, "Am I now ready to make some changes."
- Jack Canfield

Keep going, for success lies just around the corner for those who refuse to quit.

Your income rarely exceeds your personal development.
- Jim Rohn

Things that matter most must never be at the mercy of things that matter least.
- Johann Wolfgang von Goethe

You are the architect of your own destiny; you are the master of your own fate; you are behind the steering wheel of your life. There are no limitations to what you can do, have, or be. Accept the limitations you place on yourself by your own thinking.
- Brian Tracy

Your habits will determine your quality of life.

All leaders are readers.
- Jim Rohn

Somebody is always doing what somebody else said couldn't be done.

The one thing that separates the winners from the losers, is, winners take action.
- Anthony Robbins

Every well-built house started with a definite plan in the form of blueprints.
- Napoleon Hill

Remember, if you want a different result, do something different.

Develop the habit of changing your habits.

Everyday is a gift, that is why it is called the present.

It is not what you say or hope, wish or intend, but only what you do that counts. Your choices tell you unerringly who you really are.
- Brian Tracy

Happiness is not getting what you want, but wanting what you've got.

Success never comes to look for you while you wait around. You've got to get up and work at it to make your dreams come true.
- Poh Yu Khing

Man alone has the power to transfer his thoughts into physical reality; man alone can dream and make his dreams come true.
- Napoleon Hill

Commit yourself to life long learning. The most valuable asset you will ever have is your mind and what you put into it.
- Brian Tracy

Success is committing to give your best no matter what the circumstances.

A time comes when you need to stop waiting for the man you want to become and start being the man you want to be.
- Bruce Springsteen

What have you done today to help you reach your lifelong goals?
- Brian Tracy

Believe you will be successful and you will.
- Dale Carnegie

The only way to discover the limits of the possible is to go beyond them into the impossible.
- Arthur C. Clark

Success is measured in terms of reaching your goals, dreams, and expectations. Your success is determined by hard work, persistence, and determination. If you are going to be a success in life it's all up to you... it's your responsibility.
- Will Horton

You are what you repeatedly do. Excellence is not an event - it is a habit.
- Aristotle

Success comes from having dreams that are bigger than your fears.
- Terry Litwiller

Hope doesn't guarantee anything - hard work does.

I feel the most important requirement to success is learning to overcome failure. You must learn to tolerate it, but never accept it.
- Reggie Jackson

Spectacular achievement is always preceded by painstaking preparation.
- Roger Staubach

Some things have to be believed to be seen.
- Ralph Hodgson

I am not discouraged, because every wrong attempt discarded is another step forward.
- Thomas Edison

We will either find a way or make one.
- Hannibal

Take a risk - jump out of your comfort zone!

Don't let self-doubt hold you back!

Overcome fear by taking action!

Hold yourself to a higher standard than anybody else expects of you.
- Henry Ward Beecher

If we did all of the things we are capable of doing, we would literally astound ourselves.
- Thomas A. Edison

Every man is an impossibility until he is born.
- Ralph Waldo Emerson

Success is having your best day everyday.

A powerful combination to ensure success is having the vision of an eagle and the heart of a lion.

The only difference between success and failure is the ability to take action.
- Alexander Graham Bell

Fear begins to melt away when you begin to take action on a goal you really want.
- Robert G. Allen

To move the world, we must first move ourselves.
- Socrates

Action must be taken at once! There is no time to be lost.
- Miguel Hidalgo

The greater the obstacle, the more glory in achieving it.
- Moliere

Where are you going? What are you doing today to get there?

It takes time to be a success, but time is all it takes.

They can because they think they can.
- Virgil

Winning starts with beginning.

If you do what you've always done, you'll get what you've always gotten.

Have a dream so BIG that you cannot achieve it until you grow into the person who can.

Success is neither a high jump nor a long jump; it is the steps of a marathon.

If opportunity doesn't knock, build a door.

Failure is never as scary as regret.

Successful people do what unsuccessful people dare not to.

Without a goal, discipline is nothing but self-punishment.

Never let a day pass that will make you say, "I will do better tomorrow".

The word can't is not in the successful man's vocabulary.

Real success is not having things, but having victory over yourself.

I haven't failed; I have just found 10,000 ways that didn't work.
- Thomas A. Edison

Tomorrow is now.
- Eleanor Roosevelt

If your life is free of failures, you are not taking enough risks.

The secret to success is to be ready when opportunity comes.
- Benjamin Disraeli

Exceed expectations. We are not driven to do extraordinary things, but to do ordinary things extraordinarily well.
- Bishop Gore

Do extraordinary things; don't just dream them.

Success is peace of mind, which is a direct result of self-satisfaction in knowing that you did your best to become the best you are capable of becoming.
- John Wooden

The world makes way for a man who knows where he is going.
- Ralph Waldo Emerson

Step by step. I can't think of any other way of accomplishing anything.
- Michael Jordan

Plan your work for today and everyday, and then work on your plan today and everyday.
- Norman Vincent Peale

The pessimist sees difficulty in every opportunity; an optimist sees the opportunity in every difficulty.
- Winston Churchill

High expectations are the key to everything.
- Sam Walton
"""
        
        // Split by double newlines to get individual quote blocks
        let quoteBlocks = quotesText.components(separatedBy: "\n\n")
        allQuotes = quoteBlocks.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    // Check if we should show a quote today
    private func checkIfShouldShowQuote() {
        // First check if quotes are enabled in settings
        guard SettingsService.shared.isQuoteEnabled else {
            shouldShowQuote = false
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDateString = UserDefaults.standard.string(forKey: lastQuoteDateKey),
           let lastDate = ISO8601DateFormatter().date(from: lastDateString) {
            let lastDateStart = calendar.startOfDay(for: lastDate)
            
            // If last quote was shown today, don't show again
            if calendar.isDate(lastDateStart, inSameDayAs: today) {
                shouldShowQuote = false
                return
            }
        }
        
        // Show a new quote
        selectRandomQuote()
        shouldShowQuote = true
    }
    
    // Select a random quote that hasn't been dismissed
    private func selectRandomQuote() {
        guard !allQuotes.isEmpty else { return }
        
        // Get dismissed quotes
        let dismissedQuotes = UserDefaults.standard.stringArray(forKey: dismissedQuotesKey) ?? []
        
        // Filter out dismissed quotes
        var availableQuotes = allQuotes.filter { !dismissedQuotes.contains($0) }
        
        // If all quotes have been dismissed, reset
        if availableQuotes.isEmpty {
            availableQuotes = allQuotes
            UserDefaults.standard.removeObject(forKey: dismissedQuotesKey)
        }
        
        // Select random quote
        if let randomQuote = availableQuotes.randomElement() {
            currentQuote = randomQuote
        }
    }
    
    // Mark quote as shown for today
    func markQuoteAsShown() {
        let today = Date()
        let dateString = ISO8601DateFormatter().string(from: today)
        UserDefaults.standard.set(dateString, forKey: lastQuoteDateKey)
    }
    
    // Dismiss quote with thumbs up (positive feedback)
    func dismissWithThumbsUp() {
        markQuoteAsShown()
        shouldShowQuote = false
    }
    
    // Dismiss quote with thumbs down (negative feedback - won't show this quote again)
    func dismissWithThumbsDown() {
        markQuoteAsShown()
        
        // Add to dismissed quotes list
        var dismissedQuotes = UserDefaults.standard.stringArray(forKey: dismissedQuotesKey) ?? []
        if !dismissedQuotes.contains(currentQuote) {
            dismissedQuotes.append(currentQuote)
            UserDefaults.standard.set(dismissedQuotes, forKey: dismissedQuotesKey)
        }
        
        shouldShowQuote = false
    }
}
