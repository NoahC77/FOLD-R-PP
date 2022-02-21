# FOLD-R-PP
The implementation details of FOLD-R++ algorithm and how to use it are described here. The target of FOLD-R++ algorithm is to learn an answer set program for a classification task. Answer set programs are logic programs that permit negation of predicates and follow the stable model semantics for interpretation. The rules generated are essentially default rules. Default rules (with exceptions) closely model human thinking.

## Installation
Only function library:

<code>
	
	python3 -m pip install foldrpp
	
</code>

With the dataset examples:

<code>
	
	git clone https://github.com/hwd404/FOLD-R-PP.git
	
</code>

### Prerequisites
The FOLD-R++ algorithm is developed with only python3. No extra library is needed.
<!-- Numpy is the only dependency:

<code>
	
	python3 -m pip install numpy
	
</code> -->

## Instruction

A simple example can be found in **example.py**

### Data preparation

The FOLD-R++ algorithm takes tabular data as input, the first line for the tabular data should be the feature names of each column.
The FOLD-R++ algorithm does not have to encode the data for training. It can deal with numerical, categorical, and even mixed type features (one column contains both categorical and numerical values) directly.
However, the numerical features should be identified before loading the data, otherwise they would be dealt like categorical features (only literals with = and != would be generated).

There are many UCI example datasets that have been used to pre-populate the **data** directory. Code for preparing these datasets has already been added to datasets.py.


For example, the UCI kidney dataset can be loaded with the following code:

<code>
	
    attrs = ['age', 'bp', 'sg', 'al', 'su', 'rbc', 'pc', 'pcc', 'ba', 'bgr', 'bu', 'sc', 'sod', 'pot', 'hemo', 'pcv',
             'wbcc', 'rbcc', 'htn', 'dm', 'cad', 'appet', 'pe', 'ane']
    nums = ['age', 'bp', 'sg', 'bgr', 'bu', 'sc', 'sod', 'pot', 'hemo', 'pcv', 'wbcc', 'rbcc']
    model = Classifier(attrs=attrs, numeric=nums, label='label', pos='ckd')

    data = model.load_data('data/kidney/kidney.csv')
    data_train, data_test = split_data(data, ratio=0.8, rand=True)

    X_train, Y_train = split_xy(data_train)
    X_test,  Y_test = split_xy(data_test)
	
</code>

**attrs** lists all the features needed, **nums** lists all the numerical features, **label** is the name of the output classification label, **pos** indicates the positive value of the label, **model** is an initialized classifier object with the configuration of kidney dataset. **Note: For binary classification tasks, the label value with more examples should be selected as the label's positive value**.

### Training
The FOLD-R++ algorithm generates an explainable model that is represented by an answer set program for classification tasks. Here's a training example for kidney dataset:

<code>
	
    model.fit(X_train, Y_train, ratio=0.5)
	
</code>

Note that the hyperparameter **ratio** in **fit** function can be set by the user, and ranges between 0 and 1. Default value is 0.5. This hyperparameter represents the ratio of training examples that are part of the exception to the examples implied by only the default conclusion part of the rule. We recommend that the user experiment with this hyperparameter by trying different values to produce a ruleset with the best F1 score. A range between 0.2 and 0.5 is recommended for experimentation.

The rules generated by foldrpp will be stored in the model object. These rules are organized in a nested intermediate representation. The nested rules will be automatically flattened and decoded to conform to the syntax of answer set programs by calling **print_asp** function: 

<code>
	
    model.print_asp()
	
</code>

An answer set program, compatible with the s(CASP) answer set programming system, is printed as shown below. The s(CASP) system is a system for direclty executing predicate answer set programs in a query-driven manner.

<code>

	% the answer set program generated by foldr++:
	label(X,'ckd') :- sc(X,N11), N11>1.2. 
	label(X,'ckd') :- sg(X,N2), N2=<1.015. 
	label(X,'ckd') :- hemo(X,N14), N14=<12.7. 
	label(X,'ckd') :- not al(X,'0'), sg(X,N2), N2=<1.025. 
	label(X,'ckd') :- su(X,'2'). 
	% acc 1.0 p 1.0 r 1.0 f1 1.0
	% foldr++ costs:  0:00:00.016192 
	
</code>

### Testing in Python
Given **X_test**, a list of test data samples, the Python **predict** function will predict the classification outcome for each of these data samples. 

<code>
	
	Y_test_hat = model.predict(X_test)

</code>

The **classify** function can also be used to classify a single data sample.
	
<code>
	
	y_test_hat = model.classify(x_test)

</code>

#### The code of the above examples can be found in **main.py**. The examples below with more datasets and more functions can be found in **example.py**

### Save model and Load model

<code>
	
    save_model_to_file(model, 'example.model')
    model2 = load_model_from_file('example.model')
    save_asp_to_file(model2, 'example.lp')

</code>

A trained model can be saved to a file with **save_model_to_file** function. **load_model_from_file** function helps load model from file.
The generated ASP program can be saved to a file with **save_asp_to_file** function.
	
### Explanation and Proof Tree

FOLD-R++ provides simple format explanation for predictions with **explain** function, the parameter **all_flag** means whether or not to list all the answer sets. 

<code>
	
	model.explain(X_test[i], all_flag=True)
	
</code>

Here is an example for a instance from cars dataset. The generated answer set program is :

<code>
	
	% cars dataset 1728 7
	label(X,'negative') :- persons(X,'2'). 
	label(X,'negative') :- safety(X,'low'). 
	label(X,'negative') :- buying(X,'vhigh'), maint(X,'high'). 
	label(X,'negative') :- maint(X,'vhigh'), not buying(X,'low'), not ab4(X). 
	label(X,'negative') :- lugboot(X,'small'), safety(X,'med'), buying(X,'high'). 
	ab1(X) :- lugboot(X,'small'), safety(X,'med'). 
	ab2(X) :- doors(X,'2'), not lugboot(X,'big'), safety(X,'med'). 
	ab3(X) :- doors(X,'2'), lugboot(X,'small'), persons(X,'more'). 
	ab4(X) :- buying(X,'med'), not ab1(X), not ab2(X), not ab3(X). 
	% acc 0.9538 p 1.0 r 0.935 f1 0.9664
	% foldr++ costs:  0:00:00.029924 

</code>

And the generated justification for an instance predicted as positive:

<code>
	
	Explanation for example number 13 :
	answer 1:
	[T]label(X,'negative') :- [T]persons(X,'2'). 
	{'persons: 2'}
	answer 2:
	[T]label(X,'negative') :- [T]safety(X,'low'). 
	{'safety: low'}
	answer 3:
	[F]ab4(X) :- [F]buying(X,'med'), not [U]ab1(X), not [U]ab2(X), not [U]ab3(X). 
	[T]label(X,'negative') :- [T]maint(X,'vhigh'), not [F]buying(X,'low'), not [F]ab4(X). 
	{'buying: high', 'maint: vhigh'}

</code>

There are 3 answers have been generated for the current instance, because **all_flag** has been set as True when calling **explain** function. Only 1 answer will be generated if **all_flag** is False. In the generated answers, each literal has been tagged with a label. **[T]** means True, **[F]** means False, and **[U]** means unnecessary to evaluate. And the smallest set of features of the instance is listed for each answer.

FOLD-R++ also provide proof tree for predictions with **proof** function, the parameter **all_flag** means whether or not to list all the answer sets. 

<code>
	
	model.proof(X_test[i], all_flag=True)
	
</code>
	
And generate proof tree for the instance above:

<code>
	
	Proof Trees for example number 13 :
	answer 1:
	label(X,'negative') DOES HOLD because 
		the value of persons is '2' which should equal '2' (DOES HOLD) 
	{'persons: 2'}
	answer 2:
	label(X,'negative') DOES HOLD because 
		the value of safety is 'low' which should equal 'low' (DOES HOLD) 
	{'safety: low'}
	answer 3:
	label(X,'negative') DOES HOLD because 
		the value of maint is 'vhigh' which should equal 'vhigh' (DOES HOLD) 
		the value of buying is 'high' which should not equal 'low' (DOES HOLD) 
		exception ab4 DOES NOT HOLD because 
			the value of buying is 'high' which should equal 'med' (DOES NOT HOLD) 
	{'buying: high', 'maint: vhigh'}

</code>

For an instance predicted as negative, there' no answer set. Instead, the explaination has to list the rebuttals for all the possible rules, and the parameter **all_flag** will be ignored:

<code>
	
	Explanation for example number 15 :
	rebuttal 1:
	[F]label(X,'negative') :- [F]persons(X,'2'). 
	{'persons: more'}
	rebuttal 2:
	[F]label(X,'negative') :- [F]safety(X,'low'). 
	{'safety: med'}
	... ...
	rebuttal 5:
	[F]label(X,'negative') :- [T]lugboot(X,'small'), [T]safety(X,'med'), [F]buying(X,'high'). 
	{'lugboot: small', 'safety: med', 'buying: med'}

</code>

<code>

	Proof Trees for example number 15 :
	rebuttal 1:
	label(X,'negative') DOES NOT HOLD because 
		the value of persons is 'more' which should equal '2' (DOES NOT HOLD) 
	{'persons: more'}
	rebuttal 2:
	label(X,'negative') DOES NOT HOLD because 
		the value of safety is 'med' which should equal 'low' (DOES NOT HOLD) 
	{'safety: med'}
	... ...
	rebuttal 5:
	label(X,'negative') DOES NOT HOLD because 
		the value of lugboot is 'small' which should equal 'small' (DOES HOLD) 
		the value of safety is 'med' which should equal 'med' (DOES HOLD) 
		the value of buying is 'med' which should equal 'high' (DOES NOT HOLD) 
	{'lugboot: small', 'safety: med', 'buying: med'}

</code>
	
### Justification by using s(CASP)
**The installation of s(CASP) system is necessary for this part. The above examples do not need the s(CASP) system.**

Classification and its justification can be conducted with the s(CASP) system. However, each data sample needs to be converted into predicate format that the s(CASP) system expects. The **load_data_pred** function can be used for this conversion; it returns the data predicates string list. The parameter **numerics** lists all the numerical features.

<code>
	
	nums = ['Age', 'Number_of_Siblings_Spouses', 'Number_Of_Parents_Children', 'Fare']
	X_pred = load_data_pred('data/titanic/test.csv', numerics=nums)

</code>

Here is an example of the answer set program generated for the titanic dataset by FOLD-R++, along with a test data sample converted into the predicate format.

<code>

	survived(X,'0'):-class(X,'3'),not sex(X,'male'),fare(X,N4),N4>23.25,not ab7(X),not ab8(X).
	survived(X,'0'):-sex(X,'male'),not ab2(X),not ab4(X),not ab6(X).
	... ...
	ab7(X):-number_of_parents_children(X,N3),N3=<0.0.
	ab8(X):-fare(X,N4),N4>31.275,fare(X,N4),N4=<31.387.
	... ...
	
	id(1).
	sex(1,'male').
	age(1,34.5).
	number_of_siblings_spouses(1,0.0).
	number_of_parents_children(1,0.0).
	fare(1,7.8292).
	class(1,'3').
</code> 

An easier way to get justification from the s(CASP) system is to call **scasp_query** function. It will send the generated ASP rules, converted data and a query to the s(CASP) system for justification. A previously specified natural language **translation template** can make the justification easier to understand, but is **not necessary**. The template indicates the English string corresponding to a given predicate that models a feature. Here is a (self-explanatory) example of a translation template:

<code>
	
	#pred sex(X,Y) :: 'person @(X) is @(Y)'.
	#pred age(X,Y) :: 'person @(X) is of age @(Y)'.
	#pred number_of_sibling_spouses(X,Y) :: 'person @(X) had @(Y) siblings or spouses'.
	... ...
	#pred ab2(X) :: 'abnormal case 2 holds for @(X)'.
	#pred ab3(X) :: 'abnormal case 3 holds for @(X)'.
	... ...
	
</code>

The template file can be loaded to the model object with **load_translation** function. Then, the justification is generated by calling **scasp_query**. If the input data is in predicate format, the parameter **pred** needs to be set as True.

<code>
	
	load_translation(model, 'data/titanic/template.txt')
	print(scasp_query(model, x, pred=False))
	
</code>

Here is the justification for a passenger in the titanic example above (note that survived(1,0) means that passenger with id 1 perished (denoted by 0):

<code>

	% QUERY:I would like to know if
	'goal' holds (for 0).

	ANSWER:	1 (in 2.049 ms)

	JUSTIFICATION_TREE:
	'goal' holds (for 0), because
	    'survived' holds (for 0, and 0), because
		person 0 paid 7.8292 for the ticket, and
		person 0 is of age 34.5.
	The global constraints hold.

	MODEL:
	{ goal(0),  survived(0,0),  not sex(0,female),  not ab2(0),  not fare(0,Var0 | {Var0 \= 7.8292}),  fare(0,7.8292),  not ab4(0),  not class(0,1),  not ab6(0),  not age(0,Var1 | {Var1 \= 34.5}),  age(0,34.5) }

</code>


### s(CASP)

All the resources of s(CASP) can be found at https://gitlab.software.imdea.org/ciao-lang/sCASP.

## Citation

<code>
	
	@misc{wang2021foldr,
	      title={FOLD-R++: A Scalable Toolset for Automated Inductive Learning of Default Theories from Mixed Data}, 
	      author={Huaduo Wang and Gopal Gupta},
	      year={2021},
	      eprint={2110.07843},
	      archivePrefix={arXiv},
	      primaryClass={cs.LG}
	}
	
</code>
<code>

	@article{DBLP:journals/corr/abs-1804-11162,
		author={Joaqu{\'{\i}}n Arias and Manuel Carro and Elmer Salazar and Kyle Marple and Gopal Gupta},
		title={Constraint Answer Set Programming without Grounding},
		journal={CoRR},
		volume={abs/1804.11162},
		year={2018},
		url={http://arxiv.org/abs/1804.11162}
	}

</code>

## Acknowledgement
	
Authors gratefully acknowledge support from NSF grants IIS 1718945, IIS 1910131, IIP 1916206, and from Amazon Corp, Atos Corp and US DoD.
