class Comprehension
    @$inject : ['Currency']

    constructor : (@currency) ->
        @currency.list

    getPropositions : (query) =>
        #LowerCase the query for easier comparisons
        query = do query.toLowerCase

        #Initialize data structures
        currencies = []
        numbers = []
        propositions = []

        [query, currencies] = matchCurrency query, @currency

        #Set defoult values if nothing was found
        currencies = (defaultCurrencies @currency) if currencies.length <= 0
        numbers = (do defaultNumbers) if numbers.length <= 0

        #Compute all numbers with all currencies
        currencies.map (currency) =>
            numbers.map (number) =>
                propositions.push
                    label : "#{number} #{currency[0]}"
                    currency : currency[1]
                    number : number

        #Finally return the propositions
        propositions

    matchCurrency = (query, currency) =>
        matched = {}
        words = query.split /\s+/
        max = 0
        strippedQuerry = query

        for iso, curr of currency.list
            name = do curr.name.toLowerCase
            #Match ISO codes
            if query.match do iso.toLowerCase
                strippedQuerry = strippedQuerry.replace do iso.toLowerCase, ''
                matched[iso] = [curr.name]
            #Or do a word comparison
            else
                num = 0
                words.map (word) =>
                    if name.match word
                        ++num
                        matched[iso] = [curr.name, num]
                        strippedQuerry = strippedQuerry.replace word, ''
                max = num if num > max

        #Keep only the best matches
        matches = []
        for iso, curr of matched
            if not curr[1]? or curr[1] is max
                matches.push [curr[0], iso]

        #Finally return the new query and the matches
        [strippedQuerry, matches]

    defaultCurrencies = (currency) =>
        ['USD', 'EUR', 'GBP'].map (iso) -> [currency.list[iso].name, iso]

    defaultNumbers = () =>
        [100000]

angular.module('storiesServices').service "comprehensionService", Comprehension